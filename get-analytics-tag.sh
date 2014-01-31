#!/bin/bash

address=$1
page=$2
mintaxlength="9"
maxtaglength="17"
timeout=5

file=`more $page | sed ':a;N;$!ba;s/\n/ /g' | sed 's/ //g' | sed -r 's/^(.+)src="([^"]+(common\-min\.js|webtrends[^\?\/]*\.js|analytics\.js|wt\.js|min\.js|preload\-min\.js)[^"]*)"(.+)$/\2/'`

# check to see if it is an fully qualified address or not
findhttp=`echo $file | grep -i "http" | wc -l | sed 's/ //g'`

if [ $findhttp == 1 ]; then
	#full qualified
	jstag=`curl -m $timeout -sk $file | sed ':a;N;$!ba;s/\n/ /g' | sed 's/ //g' | sed -r 's/^(.+)(UA\-\d{4-9}\-\d{1-4})(.+)/\2/g'`
else
	#local file, prepend address
	jstag=`curl -m $timeout -sk $address$file | sed ':a;N;$!ba;s/\n/ /g' | sed 's/ //g' | sed -r 's/^(.+)(UA\-\d{4-9}\-\d{1-4})(.+)/\2/g'`
fi

jstaglength=`echo $jstag | wc -m | sed 's/ //g'`

if [ "$jstaglength" >= "$mintaglength" ] && [ "$jstaglength" <= "$maxtaglength" ]; then
	echo $jstag
fi
