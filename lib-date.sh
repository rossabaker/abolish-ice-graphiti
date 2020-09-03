#!/usr/bin/env bash

# detect GNU date vs BSD date and provide wrapper functions

_iso="%Y-%m-%d"
_time="%H:%M:%S"
_timeandzone="%T%Z"
_day="%u"
dateformat="$_iso"


if date --date 2020-08-17 > /dev/null 2>&1; then
    _gnudate=1
fi

### Utility Functions

# adds a plus sign to positive numbers
add_sign() {
    if [ "$1" -gt 0 ]; then
	echo "+$1"
    else
	echo "$1"
    fi
}


### Functions that Output Dates

# returns current date in appropriate format
get_current_date() {
    date "+$dateformat"
}

# optionally takes a date, and returns the day of week as an int 0-6 (Sun-Sat)
# shellcheck disable=SC2120
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

    dow="$((dow % 7))"
    echo $dow
}

# takes a date and adds (or subtracts) a given number of days
add_days() {
    date="$1"
    days="$(add_sign "$2")"

    if [ -z "$_gnudate" ]; then
	newdate="$(date -j -v"$days"d -f "$dateformat" "$date" "+$dateformat")"
    else
        newdate="$(date --date "$date $days days" "+$dateformat")"
    fi

    echo "$newdate"
}

# takes a date and adds (or subtracts) a given number of weekss
add_weeks() {
    date="$1"
    weeks="$(add_sign "$2")"

    if [ -z "$_gnudate" ]; then
	newdate="$(date -j -v"$weeks"w -f "$dateformat" "$date" "+$dateformat")"
    else
        newdate="$(date --date "$date $weeks weeks" "+$dateformat")"
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

### Functions that Output Times

# takes a date and adds (or subtracts) a given number of seconds
add_seconds() {
    date="$1"
    secs="$(add_sign "$2")"

    if [ -z "$_gnudate" ]; then
	newtime="$(date -j -v"$secs"S -f "$dateformat" "$date" "+$_time")"
    else
        newtime="$(date --date "$date $secs secs" "+$_time")"
    fi

    echo "$newtime"
}

# same as above but doesn't bother to ask for a date
sec_to_time() {
    secs="$(add_sign "$1")"

    if [ -z "$_gnudate" ]; then
	newtime="$(date -j -u -v"$secs"S -f "$_timeandzone" "00:00:00UTC" "+$_time")"
    else
        newtime="$(date --date "00:00:00UTC $secs secs" "+$_time")"
    fi

    echo "$newtime"
}
