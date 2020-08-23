#!/usr/bin/env bash

# detect GNU date vs BSD date and provide wrapper functions

_iso="%Y-%m-%d"
_day="%u"
dateformat="$_iso"


date --date 2020-08-17 2>1 > /dev/null

if [ $? -eq 0 ]; then
    _gnudate=1
fi


# returns current date in appropriate format
get_current_date() {
    if [ -z $_gnudate ]; then
	date "+$dateformat"
    else
	date "+$dateformat"
    fi
}

# takes a date and returns the day of week as an int 0-6 (Sun-Sat)
get_dow() {
    date="$1"
    if [ -z "$_gnudate" ]; then
	dow="$(date -j -f "$dateformat" "$date" "+$_day")"
    else
	dow="$(date --date "$date" "+$_day")"
    fi
    dow="$(($dow % 7))"
    echo $dow
}

# adds a plus sign to positive numbers
add_sign() {
    if [ "$1" -ge 0 ]; then
	echo "+$1"
    else
	echo "$1"
    fi
}

# take a date and add (or subtract) some number of days
add_days() {
    date="$1"
    days="$(add_sign $2)"

    if [ -z "$_gnudate" ]; then
	newdate="$(date -j -v"$days"d -f "$dateformat" "$date" "+$dateformat")"
    else
        newdate="$(date --date "$date $days days" "+$dateformat")"
    fi

    echo "$newdate"
}

one_year_ago() {
    days="$(get_dow $(get_current_date))"
    if [ -z "$_gnudate" ]; then
	yearago="$(date -j -v-"$days"d -v-"52"w "+$dateformat")"
    else
	yearago="$(date --date "-$days days -52 weeks" "+$dateformat")"
    fi

    echo "$yearago"
}
