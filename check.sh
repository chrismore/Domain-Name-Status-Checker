#!/bin/bash

# This script takes a text input list of domains and checks their status
# The output of the script are wiki bullets
# Author: Chris More

## Settings ##

inputfile="input.txt"
exec `sort -f -o $inputfile $inputfile`
output="output.txt"
analytics_string="webtrendslive.com"
check_analytics_coverage=1

#####

total_websites=0
total_analytics=0
total_ok=0
total_error=0
total_redirect=0
total_ftp=0
today=`date +%m-%d-%Y`

input=`cat $inputfile`

echo "The following list and updates is as of $today

	{| class='wikitable sortable' border='1'
	|-
	! scope='col' | Web Address
	! scope='col' | Status
	! scope='col' | Analytics Installed
	! scope='col' | Analytics Page Coverage" > $output

for address in $input; do

	coverage=0

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
	if [ $response == "200" ] || [ $response == "226" ]; then
		status="Ok"
		check_html_url="$pro://$address"
		(( total_ok++ ))
	elif [ $response == "404" ]; then
		status="Error: $response Not Found"
		(( total_error++ ))
	elif [ $response == "500" ]; then
		status="Error: $response Internal Server Error"
		(( total_error++ ))
	elif [ $response == "301" ] || [ $response == "302" ]; then
		# Check to see if a website is just redirecting from http to https
		website_redirected=$(curl --write-out %{redirect_url} --silent --output /dev/null $pro://$address)
		if [ "https://$address/" == "$website_redirected" ]; then
			pro="https"
			# Check redirector again incase it redirects a second time (localization)
			website_redirected2=$(curl --write-out %{redirect_url} --silent --output /dev/null $website_redirected)
			if [ "$website_redirected2" == "" ]; then
				#If the website did not redirect again after switching to https, then set check_html_url to current address.
				status="Ok"
				check_html_url=$website_redirected
				(( total_ok++ ))
			else
				#If the website redirected a second time, set the check_html_url variable to the second redirected address.
				status="Ok"
				check_html_url=$website_redirected2
				(( total_ok++ ))
			fi
			
		else
			status="Redirected: $website_redirected"
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

	#Check to see if the website has analytics code installed

	if [ "$status" == "Ok" ] && [ "$pro" != "ftp" ]; then
		#Only check if the website is not redirecting or erroring out
		analytics_check=$(curl --silent $check_html_url | grep -i $analytics_string | wc -m | sed 's/ //g')

		if [ "$analytics_check" == "0" ]; then
			analytics="No"
		else
			analytics="Yes"
			(( total_analytics++ ))
			if [ $coverage != 0 ]; then
				#Spider every page on the website to determine the % of pages with analytics
				echo "Spidering $address..."
				coverage=`./find-analytics.sh $check_html_url $analytics_string`
			else
				coverage="N/A"
			fi
		fi
	else
		analytics="N/A"
		analytics_check=0
	fi

	echo "$address, $response, $analytics ($analytics_check)"
	echo "| [$pro://$address $address] || $status || $analytics || $coverage%" >> $output
done

echo "|}

== Statistics ==

* Total Websites: $total_websites
* Total FTP servers: $total_ftp
* Total Ok: $total_ok
* Total Errors: $total_error
* Total Redirects: $total_redirect
* Total Analytics Installed: $total_analytics

The source script for this page can be found at [https://github.com/chrismore/Domain-Name-Status-Checker here]." >> $output
