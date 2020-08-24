#!/usr/bin/env bash

# detect GNU date vs BSD date and provide wrapper functions

_iso="%Y-%m-%d"
_day="%u"
dateformat="$_iso"


date --date 2020-08-17 2>&1 > /dev/null

if [ $? -eq 0 ]; then
    _gnudate=1
fi


# returns current date in appropriate format
get_current_date() {
    date "+$dateformat"
}

# optionally takes a date, and returns the day of week as an int 0-6 (Sun-Sat)
get_dow() {
    if [ $# -eq 0 ]; then
	dow="$(date "+$_day")"
    else
	date="$1"
	if [ -z "$_gnudate" ]; then
	    dow="$(date -j -f "$dateformat" "$date" "+$_day")"
	else
	    dow="$(date --date "$date" "+$_day")"
	fi
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

# takes a date and adds (or subtracts) a given number of days
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

# not strictly speaking a year, but the begining of the github cotribution graph. 52 weeks + dow days ago
one_year_ago() {
    days="$(get_dow)"
    if [ -z "$_gnudate" ]; then
	yearago="$(date -j -v-"$days"d -v-"52"w "+$dateformat")"
    else
	yearago="$(date --date "-$days days -52 weeks" "+$dateformat")"
    fi

    echo "$yearago"
}
