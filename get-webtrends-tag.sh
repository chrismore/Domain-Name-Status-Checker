#!/bin/bash

address=$1
page=$2
taglength="31"

file=`more $page | sed ':a;N;$!ba;s/\n/ /g' | sed 's/ //g' | sed -r 's/^(.+)src="([^"]+(common\-min\.js|webtrends[^\?\/]*\.js|analytics.js|wt.js)[^"]*)"(.+)$/\2/'`

# check to see if it is an fully qualified address or not
findhttp=`echo $file | grep -i "http" | wc -l | sed 's/ //g'`

if [ $findhttp == 1 ]; then
	#full qualified
	jstag=`curl -sk $file | sed ':a;N;$!ba;s/\n/ /g' | sed 's/ //g' | sed -r 's/^(.+)(dcs.{22}\_.{4})(.+)/\2/g'`
else
	#local file, prepend address
	jstag=`curl -sk $address$file | sed ':a;N;$!ba;s/\n/ /g' | sed 's/ //g' | sed -r 's/^(.+)(dcs.{22}\_.{4})(.+)/\2/g'`
fi

jstaglength=`echo $jstag | wc -m | sed 's/ //g'`

if [ "$jstaglength" == "$taglength" ]; then
	echo $jstag
fi
