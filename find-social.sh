#!/bin/bash

inputfile="input-social.txt"
outputdir="websocial"
cat output-prod-owned.txt | sed -r 's/[\* ]+//' > $inputfile
ignore_domain="addons"
outputfile="output-social.txt"

#####

exec `cat /dev/null > $outputfile`
exec `rm -rf $outputdir > /dev/null`

input=`cat $inputfile`

for address in $input; do

	ignore_domain_check=`echo $address | grep -i -E $ignore_domain | wc -l | sed 's/ //g'`
        domain=`echo $address | sed -r 's/^(.+\/\/)([^/]+)(.*)/\2/'`

	if [ $ignore_domain_check == 0 ]; then

		echo "spidering $address"
		exec `wget -D $domain -R .swf,.JPG,.PNG,.GIF,.tiff,.bmp,*smartproxy*,.ppt,.ics,.gz,.xpi,.pdf,.exe,.rss,.js,.png,.css,.gif,.jpg,.ico,.flv,.dmg,.zip,.txt -r -q -l 1 -nc --connect-timeout=5 -P$outputdir --no-check-certificate --html-extension -U "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/9.0.1" $address` 
		exec `grep -lriE "platform\.twitter\.com|connect\.facebook\.com|twitter\.com/share|facebook\.com/sharer|twitter\.com/intent/tweet" ./$outputdir/$domain --include=*.html >> $outputfile`

		echo "deleting $domain"
		exec `rm -rf $outputdir/$domain`

	else
		echo "skipping $address"
		echo "skipping $address" >> $outputfile

	fi

done
echo "Done".
