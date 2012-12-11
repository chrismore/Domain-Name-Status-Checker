#!/bin/bash

address=$1
timeout=3

response=$(curl -m $timeout -sk --write-out %{http_code} --silent --output /dev/null http://$address)
badtitles="Authorization Required|Index of|Error|Site Temporarily Unavailable"

if [ $response != "200" ]; then
	address=$(curl -m $timeout --write-out %{url_effective} -sk --silent --output /dev/null -L http://$address)
fi

title=`curl -m 3 -sk $address | sed -n 's/.*<title>\(.*\)<\/title>.*/\1/ip;T;q'`

if [ "$title" != "" ]; then
	ignore_address=`echo $title | grep -i -E "$badtitles" | wc -l | sed 's/ //g'`

	if [ $ignore_address == 0 ]; then
		echo $title
	fi
else
	echo "$1"
fi
