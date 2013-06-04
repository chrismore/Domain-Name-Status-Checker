#!/bin/bash
# Check to see if robots are being blocked from this website.

domain=$1
timeout=5

disallow_all=0

if echo "$domain" | grep -i '^ftp'; then
	pro="ftp"
   else
	pro="http"
   fi
   
   robots_url=""

if [ $pro == "http" ]; then
	response=$(curl -m $timeout --write-out %{http_code} --silent --output /dev/null $pro://$domain/robots.txt)    
 
	if [ $response == "200" ] || [ $response == "226" ]; then
		robots_url="$pro://$domain/robots.txt"
	elif [ $response == "301" ] || [ $response == "302" ]; then
		response_https=$(curl -m $timeout --write-out %{http_code} --silent --output /dev/null https://$domain/robots.txt)
		if [ $response_https == "200" ]; then		
		robots_url="https://$domain/robots.txt"
		fi
	fi
fi

#echo "$domain: $response, $robots_url"

if [ "$robots_url" != "" ]; then
	disallow_all=$(curl -m $timeout --silent $robots_url | sed 's/^\r?\n?$//g' | grep -i "Disallow: /$" | wc -l | sed 's/ //g')
fi

echo $disallow_all
