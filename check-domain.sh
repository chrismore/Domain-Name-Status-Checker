#!/bin/bash

address=$1
input=$2
output=$3

# These are the domains that should not be scanned for page analytics due to their size and use of comprehensive templates
analytics_string="webtrendslive.com"
check_analytics_coverage=1
concurrent_procs=10

#determine if this is a website or ftp server

if echo "$address" | grep -i '^ftp'; then
               pro="ftp"
       else
               pro="http"
       fi

#Check the status code of the address
response=$(curl -k --write-out %{http_code} --silent --output /dev/null $pro://$address)        

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
	status_type="error"
elif [ $response == "301" ] || [ $response == "302" ]; then

	# Check to see if a website is just redirecting from http to https
	website_redirected=$(curl -k --write-out %{url_effective} --silent --output /dev/null -L $pro://$address)
	domain=`echo $website_redirected | sed -r 's/^(.+\/\/)([^/]+)(.*)/\2/'`

	if [[ "$domain" == "$address" ]]; then
        # website redireted, but stayed on domain.
	# Check to make sure if the website was redirected, that it did not redirected to a 404 page.
	response=$(curl -k --write-out %{http_code} --silent --output /dev/null $website_redirected)
		if [ $response == "404" ]; then
	                status="Error: $response Not Found"
  			status_type="error"
        	elif [ $response == "200" ]; then
       		 	status="Ok"
	             	status_type="ok"
                	check_html_url=$website_redirected
		else
			status="Error: cannot connect"
			status_type="error"
		fi

	elif [[ "www.$address" == $domain ]]; then	
		# Redirected to www	
		status="Ok"
          	status_type="ok"
           	check_html_url=$website_redirected
	else
		# website redirected to aother domain.
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
		ignore_domain_check=`./check-ignore.sh $check_html_url`
		
		# Check to see if analytics coverage should be performed, if the domain should be ignored.
		if [ $check_analytics_coverage == 1 ] && [ $ignore_domain_check == 0 ]; then
		
			# First check to see how many wget spiders are running. This is to keep from running too many spiders and driving up the load average.
			procs=`ps a | grep -i wget | wc -l | sed 's/ //g'`
			total_procs=`echo $procs-1|bc`
			
			while [ $total_procs -gt $concurrent_procs ]
			# If more then n wget's running, sleep for a minute and try again.
			do
				echo "Sleeping ($total_procs waiting)...."
				sleep 60
				procs=`ps a | grep -i wget | wc -l | sed 's/ //g'`
				total_procs=`echo $procs-1|bc`
				
			done
		
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
	
	
	#check to see if website is owned or external
	check_owned=`./check-owned.sh $check_html_url`

	if [ "$check_owned" == "1" ]; then
		owned="Yes"
	else
		owned="No"
	fi

else
	analytics="N/A"
	analytics_check=0
	coverage="N/A"
	owned="N/A"
fi

echo "$address, $status_type, $analytics ($analytics_check) (owned=$owned)"
status=`echo $status | sed 's/ /\+/g'` 
echo "$address,$pro,$status,$status_type,$analytics,$coverage,$owned" >> $output

## Check to see if all processes are finished to decide to run create-wiki.sh

input_len=`wc -l $input | sed -r 's/^([0-9]+) (.+)/\1/g'`
output_len=`wc -l $output | sed -r 's/^([0-9]+) (.+)/\1/g'`

if [ "$input_len" == "$output_len" ]; then
	echo "Creating wiki"
	./create-wiki.sh
	echo "Done."
fi
