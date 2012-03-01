#!/bin/bash

inputfile="input-social.txt"
outputdir="webtab"
cat output-prod-owned.txt | sed -r 's/[\* ]+//' > $inputfile
outputfile="output-moz-tab.txt"

#####

exec `cat /dev/null > $outputfile`
exec `rm -rf $outputdir > /dev/null`

input=`cat $inputfile`

for address in $input; do

        domain=`echo $address | sed -r 's/^(.+\/\/)([^/]+)(.*)/\2/'`

	echo "Scanning $address"
	exec `wget -D $domain -R .swf,.JPG,.PNG,.GIF,.tiff,.bmp,*smartproxy*,.ppt,.ics,.gz,.xpi,.pdf,.exe,.rss,.js,.png,.css,.gif,.jpg,.ico,.flv,.dmg,.zip,.txt -Q 500k -q -l 1 -r -nc --connect-timeout=5 -P$outputdir --no-check-certificate --html-extension -U "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/9.0.1" $address` 
	numberfound=`grep -lriE "(class=\"mozilla\"|moz\-tab|mozilla\-tab|tabzilla)" ./$outputdir/$domain --include=*.html | wc -l | sed 's/ //g'`

	# Some domains redirect to www.$domain and thus WGET will store them in that directory. Double check to see if that directory exists.
	if [ $numberfound -lt 1 ]; then
		numberfound=`grep -lriE "(class=\"mozilla\"|moz\-tab|mozilla\-tab|tabzilla)" ./$outputdir/www.$domain --include=*.html | wc -l | sed 's/ //g'`
	fi

	if [ $numberfound -ge 1 ]; then
		echo "$address" >> $outputfile
	fi

	echo "deleting $domain"
	exec `rm -rf $outputdir/$domain`

done
echo "Done".
