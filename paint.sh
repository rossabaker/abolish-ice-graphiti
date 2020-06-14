#!/usr/bin/env bash
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
git push origin $(git rev-parse --abbrev-ref HEAD)
