#!/usr/bin/env bash

set -e

iso="+%Y-%m-%d"
start="${1:-$(date $iso)}"
dow="$(date --date "$start" '+%u')"
dow="$(($dow % 7))"
start="$(date --date "$start -$dow days" $iso)"

echo Starting on $start ... >&2

while read line
do
	for i in $line
	do
		[ -z "$i" ] && continue
		[ "$i" -ge 0 -a "$i" -lt 7 ] || continue

		myday="$(date --date "$start +$i days" $iso)"
		echo ${myday}-4
	done

	start="$(date --date "$start +7 days" $iso)"
done
