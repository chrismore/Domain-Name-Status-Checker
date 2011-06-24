#!/bin/bash

address=$1
input=$2
output=$3

domain=`echo $address | sed -r "s/^(.+\/\/)([^/]+)(.*)/\2/"`
found=`grep -i $domain $input | wc -l | sed -r "s/ //g"`

if [ "$found" == "0" ]; then

	title=`curl -s $address | grep -i "title>" | sed ':a;N;$!ba;s/\n//g' | sed -r "s/^[^<]+//g" | sed -r "s/<(title|TITLE)>//g" | sed -r "s/<\/(title|TITLE)>//g" | sed -r "s/([^<]+)(.*)/\1/g" | sed 's/[^a-z0-9\-\: ]*$//g'`

	if [ "$title" != "Index of " ] && [ "$title" != "" ]; then

echo "== $title ==
* Prod URL:  $address
* Stage URL:
* Code Repo:
* L10N Repo:
* Code:
* Licensing:
* Product Owner:
* Dev Team:
* QA Lead:
* Team Email:
* Last reviewed:
" >> $output

	fi

fi
