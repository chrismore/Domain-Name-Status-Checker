#!/bin/bash

## This script will spider a website and download all HTML pages and then determine
# what % have analytics installed. This script can run independantly ot together with the check.sh script.
# Author: Chris More

domain=$1
analytics_string=$2
# Remove all spider cache
exec `rm -rf web > /dev/null`
exec `rm -rf hts* > /dev/null`
# Spider every page, which requires HTTrack + libssl.so installed
exec `httrack "$domain" -w -T5 -p1 -N3 -Q -%x -I0 -A9999999999 -%c10 -c5 -F "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1" > /dev/null`
# Grep for the number of pages that include the analytics string - stop at first occourance of string in file
finds=`find ./web -name "*.html" | xargs grep -sicl $analytics_string | wc -l | sed 's/ //g'`
# Find how many HTML pages have been spidered
files=`find ./web -name "*.html" | wc -l | sed 's/ //g'`
if [ $files -ge 2 ]; then
	# If more then one page is returned, then calculate the percentage
	echo "scale=2; $finds*100/$files" | bc
else
	# Return 0 if none or one pages returned total.
	echo "0"
fi