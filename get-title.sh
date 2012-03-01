#!/bin/bash

address=$1

response=$(curl --write-out %{http_code} --silent --output /dev/null http://$address)
badtitles="Authorization Required"

if [ $response != "200" ]; then
	address=$(curl --write-out %{url_effective} --silent --output /dev/null -L http://$address)
fi

title=`curl -s $address | grep -i "title>" | sed ':a;N;$!ba;s/\n//g' | sed -r "s/^[^<]+//g" | sed -r "s/<(title|TITLE)>//g" | sed -r "s/<\/(title|TITLE)>//g" | sed -r "s/([^<]+)(.*)/\1/g" | sed 's/[^a-z0-9\-\: ]*$//g'`

if [ "$title" != "" ]; then
	ignore_address=`echo $title | grep -i -E "$badtitles" | wc -l | sed 's/ //g'`

	if [ $ignore_address == 0 ]; then
		echo $title
	fi
fi
