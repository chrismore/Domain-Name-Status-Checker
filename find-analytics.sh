#!/bin/bash

## This script will spider a website and download all HTML pages and then determine
# what % have analytics installed. This script can run independantly ot together with the check.sh script.
# Author: Chris More

address=$1
analytics_string=$2
domain=`echo $address | sed -E "s/^(.+\/\/)([^/]+)(.*)/\2/"`
# Remove all spider cache
# Spider every page, which requires HTTrack + libssl.so installed
#exec `httrack "$address" -w -T5 -p1 -N3 -Q -%x -I0 -A9999999999 -%c10 -c5 -F "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1" > /dev/null`
exec `wget -D $domain -R *smartproxy*,.ppt,.ics,.gz,.xpi,.pdf,.exe,.rss,.js,.png,.css,.gif,.jpg,.ico,.flv,.dmg,.zip,.txt -r -q -l99999 -nc --connect-timeout=5 -Pweb --no-check-certificate --html-extension -U "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/4.0.1" $address` 
# Grep for the number of pages that include the analytics string - stop at first occourance of string in file
finds=`grep -lri "$analytics_string" ./web/$domain | wc -l | sed 's/ //g'`
# Find how many HTML pages have been spidered
files=`find ./web/$domain -type f \( -name "*.html" -or -name "*.htm" \) | wc -l | sed 's/ //g'`
# There are some files that are mirroed that are behind a proxy, which are not part of the website, but wget still picks them up. The -E 'string' supports regex matching
ignore_files=`find ./web/$domain -type f \( -name "*.html" -or -name "*.htm" \) | grep -i -E 'smartproxy' | wc -l | sed 's/ //g'`
# Subtract the ignored files from files to get a final number.
files=`echo $files-$ignore_files|bc`
#echo "found $finds files with string out of $files files"
if [ $files -ge 2 ]; then
	# If more then one page is returned, then calculate the percentage
	echo "scale=2; $finds*100/$files" | bc
else
	# Return 0 if none or one pages returned total.
	echo "0"
fi