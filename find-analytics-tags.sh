#!/bin/bash

## This script will spider a website and download all HTML pages and then determine what webtrend tags are embedded

outputdir="web"
address=$1
domain=`echo $address | sed -r "s/^(.+\/\/)([^/]+)(.*)/\2/"`
outputtag="output-tag.txt"
maxmb="500m"
taglength="31"
currentfx="13"
oldfx="9"
bedrock_string="doctype html"
bedrock_responsive="initial-scale"

exec `rm -rf $outputdir/$domain`
exec `cat /dev/null > $outputtag`

echo "using current firefox"
exec `wget -e robots=off -D $domain -R .swf,.JPG,.PNG,.GIF,.tiff,.bmp,*smartproxy*,.ppt,.ics,.gz,.xpi,.pdf,.exe,.rss,.js,.png,.css,.gif,.jpg,.ico,.flv,.dmg,.zip,.txt -r -q --connect-timeout=5 -Q $maxmb -P$outputdir --no-check-certificate --html-extension -U "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/$currentfx.0" $address` 

echo "using old firefox"
exec `wget -e robots=off -D $domain -R .swf,.JPG,.PNG,.GIF,.tiff,.bmp,*smartproxy*,.ppt,.ics,.gz,.xpi,.pdf,.exe,.rss,.js,.png,.css,.gif,.jpg,.ico,.flv,.dmg,.zip,.txt -r -q --connect-timeout=5 -Q $maxmb -P$outputdir --no-check-certificate --html-extension -U "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/$oldfx.0" $address` 

echo "using android"
exec `wget -e robots=off -D $domain -R .swf,.JPG,.PNG,.GIF,.tiff,.bmp,*smartproxy*,.ppt,.ics,.gz,.xpi,.pdf,.exe,.rss,.js,.png,.css,.gif,.jpg,.ico,.flv,.dmg,.zip,.txt -r -q --connect-timeout=5 -Q $maxmb -P$outputdir --no-check-certificate --html-extension -U "Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1" $address` 

echo "using iphone"
exec `wget -e robots=off -D $domain -R .swf,.JPG,.PNG,.GIF,.tiff,.bmp,*smartproxy*,.ppt,.ics,.gz,.xpi,.pdf,.exe,.rss,.js,.png,.css,.gif,.jpg,.ico,.flv,.dmg,.zip,.txt -r -q --connect-timeout=5 -Q $maxmb -P$outputdir --no-check-certificate --html-extension -U "Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_0 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Version/4.0.5 Mobile/8A293 Safari/6531.22.7" $address` 

echo "using IE"
exec `wget -e robots=off -D $domain -R .swf,.JPG,.PNG,.GIF,.tiff,.bmp,*smartproxy*,.ppt,.ics,.gz,.xpi,.pdf,.exe,.rss,.js,.png,.css,.gif,.jpg,.ico,.flv,.dmg,.zip,.txt -r -q --connect-timeout=5 -Q $maxmb -P$outputdir --no-check-certificate --html-extension -U "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)" $address` 

echo "Finding pages"
pages=`find ./$outputdir/$domain -name *.html`

for page in $pages; do

    # make sure page does not include query strings
    check_querystring=`echo $page | grep -i -E '.html\?.+' | wc -l | sed 's/ //g'`

    if [ $check_querystring == 0 ]; then

	echo "checking $page"

	#tag ending in quote
	nstag=`more $page | sed ':a;N;$!ba;s/\n/ /g' | sed 's/ //g' | sed -r 's/^(.+)(dcs.{22}\_.{4})\/(.+)/\2/g'`
	
	#tag ending in slash
	jstag=`more $page | sed ':a;N;$!ba;s/\n/ /g' | sed 's/ //g' | sed -r 's/^(.+)(dcs.{22}\_.{4})\"(.+)/\2/g'`
	
	nstaglength=`echo $nstag | wc -m | sed 's/ //g'`
	jstaglength=`echo $jstag | wc -m | sed 's/ //g'`

	if [ "$nstaglength" -gt "$taglength" ]; then
                #page returned since no	tag found
                nstaglength=0
        fi

	if [ "$jstaglength" -gt "$taglength" ]; then
	
		# JS tag not found in HTML, check to see if there is an embedded JS file.
		jscheck=`./get-webtrends-tag.sh $address $page`
		jstaglength=`echo $jscheck | wc -m | sed 's/ //g'`

		# Check to see if a tag was found
		if [ $jstaglength == $taglength ]; then
			jstag=$jscheck
		fi
	fi

	echo "tag lenghts nstag=$nstaglength jstag=$jstaglength"

	# Check websites for platform specific pages
	if [ $domain == "www.mozilla.org" ]; then

		bedrock_check=`more $page | grep "$bedrock_string" | wc -l | sed 's/ //g'`
	
		if [ $bedrock_check == 0 ]; then
		
			platform="PHP"
			echo "PHP page"
		else
	
			echo "check bedrock"
                        responsive_check=`more $page | grep -i $bedrock_responsive | wc -l | sed 's/ //g'`

			if [ $responsive_check == 0 ]; then
				echo "bedrock non-responsive"
                                platform="Bedrock Non-Responsive"
                        else
				echo "bedrock responsive"
                            	platform="Bedrock Responsive"
                        fi

                fi

	else
	       platform=""
	fi

	if [ $nstaglength == 0 ]; then

		notfound=`grep -i "404: Page Not Found" $page | wc -l | sed 's/ //g'`

		if [ $notfound == 1 ]; then
			echo "$domain,$page,,,404 Not Found,$platform" >> $outputtag
                	echo "404 on page $page"
		else
			echo "$domain,$page,,,Missing All Tags,$platform" >> $outputtag
			echo "No nstag found on page $page"
		fi
	else	

		if [ $jstaglength == 0 ]; then
			#single tag on page
			echo "$domain,$page,$nstag,,JS Tag Missing,$platform" >> $outputtag
		else
			#two tags found
			if [ $nstag == $jstag ]; then
				echo "$domain,$page,$nstag,$jstag,Same Tags,$platform" >> $outputtag
			else
				echo "$domain,$page,$nstag,$jstag,Different Tags,$platform" >> $outputtag
			fi
		fi

	fi 

    fi

done

exec `rm -rf $outputdir/$domain`
