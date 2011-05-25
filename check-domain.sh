#!/bin/bash

address=$1
output=$2

ignore_domain="allizom"
websites_output="active-websites.txt"
analytics_string="webtrendslive.com"
check_analytics_coverage=1
create_active_websites_wiki=1

if [ $create_active_websites_wiki == 1 ]; then
	exec `cat /dev/null > $websites_output`
fi

coverage=0
#determine if this is a website or ftp server

if echo "$address" | grep -i '^ftp'; then
               pro="ftp"
       else
               pro="http"
       fi

#Check the status code of the address
response=$(curl --write-out %{http_code} --silent --output /dev/null $pro://$address)        

#Determine a human readable status code message
if [ $response == "200" ] || [ $response == "226" ]; then
	status="Ok"
	status_type="ok"
	check_html_url="$pro://$address"
elif [ $response == "404" ]; then
	status="Error: $response Not Found"
	status_type="error"
elif [ $response == "500" ]; then
	status="Error: $response Internal Server Error"
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
			status_type="ok"
			check_html_url=$website_redirected
		else
			#If the website redirected a second time, set the check_html_url variable to the second redirected address.
			status="Ok"
			status_type="ok"
			check_html_url=$website_redirected2
		fi
		
	else
		status="Redirected: $website_redirected"
		status_type="redirect"
	fi
elif [ $response == "000" ]; then
	status="Error: Unable to connect"
	status_type="error"
elif [ $response == "403" ]; then
	status="Error: $response Forbidden"
	status_type="error"
elif [ $response == "502" ]; then
	status="Error: $response Bad Gateway"
	status_type="error"
else
	status="Error: $response"
	status_type="error"
fi

#Check to see if the website has analytics code installed

if [ "$status" == "Ok" ] && [ "$pro" != "ftp" ]; then
	#Only check if the website is not redirecting or erroring out
	analytics_check=$(curl --silent $check_html_url | grep -i $analytics_string | wc -m | sed 's/ //g')

	if [ "$analytics_check" == "0" ]; then
		analytics="No"
		coverage="N/A"
	else
		analytics="Yes"
		if [ $check_analytics_coverage == 1 ] && [ "$check_html_url" == "${check_html_url/$ignore_domain/}" ]; then
			#Spider every page on the website to determine the % of pages with analytics
			echo "Spidering $address..."
			coverage=`./find-analytics.sh $check_html_url $analytics_string`
		else
			coverage="N/A"
		fi
		if [ coverage == 0 ]; then
			coverage="N/A"
		fi
	fi
	
	if [ $create_active_websites_wiki == 1 ]; then
		exec `./active-websites.sh $check_html_url $websites_output > /dev/null`
	fi
else
	analytics="N/A"
	analytics_check=0
	coverage="N/A"
fi

#echo "$address, $response, $analytics ($analytics_check)"
status=`echo $status | sed 's/ /\+/g'` 
echo "$address,$pro,$status,$status_type,$analytics,$coverage" >> $output