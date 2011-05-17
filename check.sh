#!/bin/bash

# This script takes a text input list of domains and checks their status
# The output of the script are wiki bullets

inputfile="input.txt"
exec `sort -f -o=$inputfile $inputfile`
output="output.txt"
total_websites=0
total_webtrends=0
total_ok=0
total_error=0
total_redirect=0
total_ftp=0
today=`date +%m-%d-%Y`

#######

input=`cat $inputfile`

echo "The following list and updates is as of $today

	{| class='wikitable sortable' border='1'
	|-
	! scope='col' | Web Address
	! scope='col' | Status
	! scope='col' | WebTrends Installed" > $output

for address in $input; do

	echo "|-" >> $output 

	#determine if this is a website or ftp server

	if echo "$address" | grep -i '^ftp'; then
                pro="ftp"
		(( total_ftp++ ))
        else
                pro="http"
		(( total_websites++ ))
        fi

	#Check the status code of the address
	response=$(curl --write-out %{http_code} --silent --output /dev/null $pro://$address)        

	#Determine a human readable status code message
	if [ $response == "200" ] || [ $response == "206" ]; then
		status="Ok"
		(( total_ok++ ))
	elif [ $response == "404" ]; then
		status="Error: $response Not Found"
		(( total_error++ ))
	elif [ $response == "500" ]; then
		status="Error: $response Internal Server Error"
		(( total_error++ ))
	elif [ $response == "301" ] || [ $response == "302" ]; then
		# Check to see if a website is just redirecting from http to https
		website=$(curl --write-out %{redirect_url} --silent --output /dev/null $pro://$address)
		if [ "https://$address/" == "$website" ]; then
			status="Ok"
			pro="https"
			(( total_ok++ ))
		else
			status="Redirected: $website"
			(( total_redirect++ ))
		fi
	elif [ $response == "000" ]; then
		status="Error: Unable to connect"
		(( total_error++ ))
	elif [ $response == "403" ]; then
		status="Error: $response Forbidden"
		(( total_error++ ))
	elif [ $response == "502" ]; then
		status="Error: $response Bad Gateway"
		(( total_error++ ))
	else
		status="Error: $response"
		(( total_error++ ))
	fi

	#Check to see if the website has WebTrends code installed

	if [ "$status" == "Ok" ]; then
		#Only check if the website is not redirecting or erroring out
		webtrends_check=$(curl --silent $pro://$address | grep -i webtrends | wc -m | sed 's/ //g')

		if [ "$webtrends_check" == "0" ]; then
			webtrends="No"
		else
			webtrends="Yes"
			(( total_webtrends++ ))
		fi
	else
		webtrends="N/A"
		webtrends_check=0
	fi

	echo "$address, $response, $webtrends ($webtrends_check)"
	echo "| [$pro://$address $address] || $status || $webtrends" >> $output
done

echo "|}

== Statistics ==

* Total Websites: $total_websites
* Total FTP servers: $total_ftp
* Total Ok: $total_ok
* Total Errors: $total_error
* Total Redirects: $total_redirect
* Total WebTrends: $total_webtrends

The source script for this page can be found at [https://github.com/chrismore/Domain-Name-Status-Checker here]." >> $output
