#!/usr/bin/env bash

font="${font:-Ubuntu}"
pt=${pt:-9}

tmpname="${tmpname:-ai.pgm}"
outname="${outname:-$(dirname "$0")/dates.txt}"

weeks=52
maxcolors=4
numcolors=${numcolors:-${maxcolors}}

usage="Usage: $0 [OPTIONS] \n
Render the text 'ABOLISH ICE' with a given font to ${outname} for use with $(dirname "$0")/paint.sh\n
\n
\t -n\t\t\t disable prompts \n
\t -f, --font <font>\t select a font (name or filepath) for rendering [default '${font}'] \n
\t -s, --size <fontsize>\t select a font size for rendering [default '${pt}'] \n
\t -c, --colors <colors>\t set the number of foreground colors to be used [maximum '${maxcolors}'] \n
\t -p, --partial\t\t render pixels to the current partial week, if needed. \n
\t -t, --temp\t\t use a temporary file for image, rather than overwriting ${tmpname} \n
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
	-p|--partial)
	    ((++weeks))
	    ;;
	-s|--size)
	    pt=$2
	    shift
	    ;;
	-c|--colors)
	    numcolors=$2
	    shift
	    ;;
	-t|--temp)
	    tmpname="/tmp/${tmpname}"
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
	 else if [ "$(head -2 ${tmpname}|tail -1)" != "7 ${weeks}" ]; then
		  echo "image must be 7x${weeks} (${weeks}x7 rotated 90 degrees, and reflected)"
		  exit 12

	      fi
	 fi
    fi
else
    # render the image to a greyscale, acsii format for easy parsing
    convert -pointsize ${pt} -font "${font}" -fill black -colors $((${numcolors}+1)) -background white -size ${weeks}x7 -gravity center label:'ABOLISH ICE' -compress none "pgm:${tmpname}"

    err=$?
    if [ ! $err ]; then
	echo "Imagemagick failed, maybe it was built without truetype or fontconfig support?"
	exit $err
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

    # give the a preview of what we'll put on the commit graph
    if [ ! -z $(which viu 2> /dev/null) ]; then
	viu "${tmpname}"
    fi

    # it's easier to process the file if we re-orient the image (can probably skip this with a smarter loop)
    mogrify -rotate 90 -flop -compress none "${tmpname}"
fi

# the greyscale colors are 16-bit colors, but we only have 5 colors to work with, 2 of which will be used for background blocks, depending on whether a given day has prior commits or not
# we want to reduce this to no more than 4 colors
I=${maxcolors}
while read line
do
    #echo $line $I
    colormap[${line}]=$I
    ((--I))
    if [ $I -eq $((${maxcolors}-${numcolors})) ]; then
	break
    fi

    # makes a list of unique colors in the image:
    #   remove 3 lines of metadata, turn 2D array of pixels into 1D, sort,
    #     remove duplicates and remove empty lines
done <<< $(tail +4 "${tmpname}"|tr ' ' '\n'|sort -n|uniq|grep -v "^$" )


# inspired by dates.sh, turns image's pixels, by position and color, into dates.txt
iso="+%Y-%m-%d"
dow="$(date --date "${start}" '+%u')"
dow="$((${dow} % 7))"
start="$(date --date "${start} -${dow} days -52 weeks" ${iso})"

echo Starting on $start ... >&2
day=0
truncate --size 0 "${outname}"

# image is already in calendar order, ${weeks} row/weeks of 7 column/days
while read line
do
    for i in $line
    do
	color=${colormap[$i]}
	if [ ! -z ${color} ]; then
	    echo "$(date --date "${start} +${day} days" ${iso})-${color}" >> "${outname}"
	fi
	((++day))
    done
done <<< $(tail +4 "${tmpname}")
