#!/usr/bin/env bash
while read line	 
do		
	IFS='/' read -ra PARAMS <<< "$line"
	D=${PARAMS[0]}
	M=${PARAMS[1]}
	Y=${PARAMS[2]}
	I=180
	if [ ! -d "$Y" ]; then
    	mkdir $Y
	fi	
		cd $Y
		if [ ! -d "$M" ]; then
			mkdir $M
		fi
			cd $M
			if [ ! -d "$D" ]; then
				mkdir $D
			fi
				cd $D
				for i in $( eval echo {1..$I} )
      			do
      				echo "$i on $D/$M/$Y" > commit.md
                                s=$(printf "%02d" $(expr $i % 60))
                                m=$(printf "%02d" $(expr $i / 60))
        			export GIT_COMMITTER_DATE="$Y-$M-$D 12:$m:$s"
        			export GIT_AUTHOR_DATE="$Y-$M-$D 12:$m:$s"
                                echo $s $m $GIT_COMMITTER_DATE $GIT_AUTHOR_DATE
        			git add commit.md -f
        			git commit --date="$Y-$M-$D 12:$m:$s" -m "$i on $M $D $Y"
        		done
        	cd ../
        cd ../
    cd ../	
done < dates.txt
git push origin master
git rm -rf 20**
git commit -am "cleanup"
git push origin master
