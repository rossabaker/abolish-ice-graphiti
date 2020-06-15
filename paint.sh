#!/usr/bin/env bash

commitmax=${commitmax:-50}

if [ ! -z "${username}" ]; then
	if [ ! -z "$(which curl 2> /dev/null)" ]; then
		fetchcmd="curl -s"
		else if [ ! -z "$(which wget 2> /dev/null)" ]; then
			fetchcmd="wget -q -O -"
		fi
	fi

	if [ ! -z "${fetchcmd}" ]; then
		max=$($fetchcmd "https://github.com/${username}"|tr '<> ' "\n"|grep data-count|tr '="' "\n"|grep -v data-count|grep -v '^$'|sort -nr|head -1)
		commitmax=${max:-${commitmax}}
	fi
fi

while read line
do
	IFS='/' read -ra PARAMS <<< "$line"
	D=${PARAMS[0]}
	M=${PARAMS[1]}
	Y=${PARAMS[2]}
	I=180
	d="$Y-$M-$D"
	for i in $( eval echo {1..$I} )
	do
		s=$(printf "%02d" $(expr $i % 60))
		m=$(printf "%02d" $(expr $i / 60))
		export GIT_COMMITTER_DATE="$d 12:$m:$s"
		export GIT_AUTHOR_DATE="$d 12:$m:$s"
		git commit --date="$d 12:$m:$s" -m "$i on $d" --no-gpg-sign --allow-empty
	done
done < dates.txt
git push origin master
