#!/usr/bin/env bash

set -e

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
	IFS='-' read -r Y M D I <<< "$line"
	I=$((${I:-4}*(${commitmax:-50}+1)))
	d="$Y-$M-$D"
	for i in $( eval echo {1..$I} )
	do
		s=$(printf "%02d" $(expr $i % 60))
		m=$(printf "%02d" $(expr $i / 60))
		export GIT_COMMITTER_DATE="$d 12:$m:$s"
		export GIT_AUTHOR_DATE="$d 12:$m:$s"
		git commit --date="$d 12:$m:$s" -m "$i on $d" --no-gpg-sign --allow-empty
	done
done < "$(dirname "$0")/dates.txt"

# Get remote name
a="$(git rev-parse --abbrev-ref HEAD@{u} || echo origin/"$(git rev-parse --abbrev-ref HEAD)")"
remote="${a%%/*}"
remote="${remote:-origin}"
branch="${a#*/}"
branch="${branch:-master}"
git push "$remote" HEAD:"$branch"

if [ $? -ne 0 ] ; then
    echo "'git push' failed: please push the current branch to the default branch of a valid github repository"
fi
