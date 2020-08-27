#!/usr/bin/env bash

set -e

# shellcheck source=lib-date.sh
source "$(dirname "$0")/lib-date.sh"

start="${1:-$(one_year_ago)}"
dow="$(get_dow "$start")"
start="$(add_days "$start" "-$dow")"

echo Starting on $start ... >&2

while read line
do
	for i in $line
	do
		[ -z "$i" ] && continue
		[ "$i" -ge 0 -a "$i" -lt 7 ] || continue

		myday="$(add_days "$start" "$i")"
		echo ${myday}-4
	done

	start="$(add_days "$start" "7")"
done
