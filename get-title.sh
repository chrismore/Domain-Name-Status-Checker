#!/bin/bash

address=$1

response=$(curl -m 10 --write-out %{http_code} --silent --output /dev/null http://$address)
badtitles="Authorization Required|Index of"

if [ $response != "200" ]; then
	address=$(curl -m 10 --write-out %{url_effective} --silent --output /dev/null -L http://$address)
fi

title=`curl -m 10 -sk $address | sed -n 's/.*<title>\(.*\)<\/title>.*/\1/ip;T;q'`

if [ "$title" != "" ]; then
	ignore_address=`echo $title | grep -i -E "$badtitles" | wc -l | sed 's/ //g'`

	if [ $ignore_address == 0 ]; then
		echo $title
	fi
else
	echo "$1"
fi
