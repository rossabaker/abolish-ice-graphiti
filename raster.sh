#!/usr/bin/env bash

set -e

font="${font:-Ubuntu}"
pt=${pt:-9}

tmpname="${tmpname:-ai.pgm}"
outname="${outname:-$(dirname "$0")/dates.txt}"

weeks=53
maxcolors=4
numcolors=${numcolors:-${maxcolors}}

usage="Usage: $0 [OPTIONS] \n
Render the text 'ABOLISH ICE' with a given font to ${outname} for use with $(dirname "$0")/paint.sh\n
\n
\t -n\t\t\t disable prompts\n
\t -f, --font <font>\t select a font (name or filepath) for rendering [default '${font}']\n
\t -s, --size <fontsize>\t select a font size for rendering [default '${pt}']\n
\t -c, --colors <colors>\t set the number of foreground colors to be used [maximum '${maxcolors}']\n
\t -p, --palette\t\t use the final palette when rasterizing, instead of greyscale\n
\t\t\t\t\tNote: seems to result in fewer colors being used, maybe worse lettering\n
\t -i, --invert\t\t Dark Mode. light text on a dark background\n
\t -b, --background\t uniform background color (uses one foreground color)\n
\t\t\t\t\tNote: if inverted this affects the text color\n
\t -w\t\t\t week-day background only\n
\t -l, --no-partial\t dont render pixels to the current partial week\n
\t -t, --temp\t\t use a temporary file for image, rather than overwriting ${tmpname}\n
\t -d, --debug\t\t debugging output\n
\t -h, --help\t\t see this message and exit"

while (( "$#" )); do
    case $1 in
	-n)
	    noprompt=1
	    ;;
	-f|--font)
	    font="$2"
	    shift
	    ;;
	-l|--no-partial)
	    ((--weeks))
	    ;;
	-s|--size)
	    pt=$2
	    shift
	    ;;
	-c|--colors)
	    numcolors=$2
	    shift
	    ;;
	-p|--palette)
	    usepalette=1
	    ;;
	-i|--invert)
	    invert=1
	    ;;
	-b|--background)
	    ((--numcolors))
	    background=1
	    ;;
	-w)
	    ((--numcolors))
	    background=1
	    weekend=1
	    ;;
	-t|--temp)
	    tmpname="/tmp/${tmpname}"
	    ;;
	-d|--debug)
	    debug=1
	    ;;
	-h|--help)
	    echo -e ${usage}
	    exit
	    ;;
    esac
    shift
done


# validation
if [ ${numcolors} -gt ${maxcolors} ]; then
    numcolors=${maxcolors}
fi


# decide if we have the tools to generate $tmpname, or if not, if we have a valid file to use
if [ -z $(which convert 2> /dev/null) ]; then
    if [ ! -f "${tmpname}" ]; then
	echo "This script requires imagemagick to be installed or an uncompressed .ngm image to be supplied."
	exit 10
    else if [ "$(head -n1 ${tmpname})" != "P2" ]; then
	     echo "only uncompressed .ngm image files are supported"
	     exit 11
	 else if [ "$(head -2 ${tmpname}|tail -1)" != "${weeks} 7" ]; then
		  echo "image must be ${weeks}x7"
		  exit 12

	      fi
	 fi
    fi
else

    # generate palette file if missing
    palettename=palette.png
    if [ ! -f ${palettename} ]; then
	convert -size 12x12 xc:#ebedf0 xc:#9be9a8 xc:#40c463 xc:#30a14e xc:#216e39 +append png:palette.png
    fi

    colorcmd=""
    if [ ! -z ${invert} ]; then
	colorcmd+="-fill white -background black "
    fi

    # palette must be specified before number of colors
    if [[ -f ${palettename} && ! -z ${usepalette} ]]; then
	# FIXME: palettename cannot be properly quoted and will probably break if there is a space
	colorcmd+="-remap ${palettename} "
    fi

    colorcmd+="-colors $((${numcolors}+2))"

    # render the image to a greyscale, acsii format for easy parsing
    convert -pointsize ${pt} -font "${font}" -size ${weeks}x7 ${colorcmd} -gravity center label:'ABOLISH ICE' -depth 8 -compress none "pgm:${tmpname}"

    # give a full color preview if we are using a palette and have viu
    if [[ ! -z ${usepalette} && ! -z $(which viu 2> /dev/null) ]]; then
	convert -pointsize ${pt} -font "${font}" -size ${weeks}x7 ${colorcmd} -gravity center label:'ABOLISH ICE' "png:${tmpname}.png";viu "${tmpname}.png";rm "${tmpname}.png"
    fi

    err=$?
    if [ ! $err ]; then
	echo "Imagemagick failed, maybe it was built without truetype or fontconfig support?"
	exit $err
    fi
fi

# you don't need root to run cargo, so why not offer to get viu, if possible
if [[ -z $noprompt && -z $(which viu 2> /dev/null) && ! -z $(which cargo 2> /dev/null) ]]; then
    read -t 5 -n 1 -p " Would you like to 'cargo install viu' for image previews [y/N]? " answer
    echo
    case ${answer} in
	y|Y )
	    cargo install viu
	    ;;
	n|N )
	    echo "   Cool, you can invoke $0 with the -n option to disable this prompt."
	    ;;
    esac
fi

# give the user a greyscale preview of what we'll put on the commit graph
if [ ! -z $(which viu 2> /dev/null) ]; then
    viu "${tmpname}"
fi

# the greyscale colors are 8-bit colors, but we only have 5 colors to work with, 2 of which will be used for background blocks, depending on whether a given day has prior commits or not
# we want to reduce this to no more than 4 colors
I=${maxcolors}
colormap=()
while read line
do
    if [ ${I} -gt $((${maxcolors}-${numcolors})) ]; then
	# bash arrays are sparse wo we can just write to the proper index
	colormap[${I}]="${line}"
	if [ ! -z ${debug} ]; then
	    echo $line $I
	fi
    else
	if [ ! -z ${debug} ]; then
	    echo " discarding ${line} ${I}"
	fi
    fi
    # lol. this gets treated like an error when $I goes to 0, so then script dies with 'set -e'
    ((--I)) || true

    # makes a list of unique colors in the image:
    #   remove 3 lines of metadata, turn 2D array of pixels into 1D, sort,
    #     remove duplicates and remove empty lines
done <<< $(tail +4 "${tmpname}"|tr ' ' '\n'|sort -n|uniq|grep -v "^$" )

if [ ! -z ${debug} ]; then
    echo "${!colormap[@]}" "${colormap[@]}"
fi

# function for looking up a color in the colormap, so that we don't need an associative array
lookup_color() {
    target=$1
    # ! iterates indices
    for i in ${!colormap[@]}
    do
	if [ ${colormap[$i]} -eq ${target} ]; then
	    echo $i
	    return
	fi
    done
}

# inspired by dates.sh, turns image's pixels, by position and color, into dates.txt

# shellcheck source=lib-date.sh
source "$(dirname "$0")/lib-date.sh"
start="$(one_year_ago)"

echo Starting on $start ... >&2

# image is not in calendar order, we iterate all the sundays first, then mondays, etc.
#    so the output is sorted before being written
while read line
do
    weeks=0
    for i in $line
    do
	color="$(lookup_color ${i})"
	if [ ! -z ${color} ]; then
	    echo "$(add_weeks "${start}" "${weeks}")-${color}"
	else if [[ ! -z ${background} ]]; then
		 if [[ $day -ne 0 && $day -ne 1 &&  $day -ne 5 && $day -ne 6 || -z ${weekend} ]]; then
		     echo "$(add_weeks "${start}" "${weeks}")-1"
		 fi
	     fi
	fi
	((++weeks))
    done
    start="$(add_days "${start}" 1)"
done <<< $(tail +4 "${tmpname}") | sort -n > ${outname}
