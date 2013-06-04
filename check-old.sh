#!/bin/bash

address=$1
days_cutoff=180
timeout=5

response=$(curl -m $timeout --write-out %{http_code} --silent --output /dev/null http://$address)

if [ $response != "200" ]; then
        address=$(curl -m $timeout --write-out %{url_effective} --silent --output /dev/null -L http://$address)
fi

exec `curl -m $timeout -I --silent $address > temp.txt`

modified_date=`grep -E "^Last-Modified:" temp.txt | sed -r 's/^(Last-Modified): (.*)/\2/g'`
date=`grep -E "^Date:" temp.txt | sed -r 's/^(Date): (.*)/\2/g'`

today=`date`

if [ "$modified_date" != "" ]; then

	start=`date +%s -d "$modified_date"`
	end=`date +%s -d "$today"`

	diff_modified=$(( ( $end - $start ) / 86400 ))

else
	diff_modified=0
fi

if [ "$date" != "" ]; then

	start=`date +%s -d "$date"`
	end=`date +%s -d "$today"`

	diff_date=$(( ( $end - $start ) / 86400 ))

else
	diff_date=0

fi

if [ "$diff_modified" -gt "$days_cutoff" ] || [ "$diff_date" -gt "$days_cutoff" ]; then
	echo "1"
else
	echo "0"
fi
