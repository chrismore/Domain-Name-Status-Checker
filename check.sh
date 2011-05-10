#!/bin/bash

# This script takes a text input list of domains and checks their status
# The output of the script are wiki bullets

inputfile="input.txt"
output="output.txt"

#######

input=`cat $inputfile`
exec `cat /dev/null > $output`

for address in $input; do

	if echo "$address" | grep '^ftp'; then
                pro="ftp://"
        else
                pro="http://"
        fi

	response=$(curl --write-out %{http_code} --silent --output /dev/null $pro$address)        

	if [ $response == "200" ] || [ $response == "206" ]; then
		status="Ok"
	elif [ $response == "404" ]; then
		status="Error: $response Not Found"
	elif [ $response == "500" ]; then
		status="Error: $response Internal Server Error"
	elif [ $response == "301" ] || [ $response == "302" ]; then
		# Check to see if a website is just redirecting from http to https
		website=$(curl --write-out %{redirect_url} --silent --output /dev/null $pro$address)
		if [ "https://$address/" == "$website" ]; then
			status="Ok"
		else
			status="Redirected: $website"
		fi
	elif [ $response == "000" ]; then
		status="Error: Unable to connect"
	elif [ $response == "403" ]; then
		status="Error: $response Forbidden"
	elif [ $response == "502" ]; then
		status="Error: $response Bad Gateway"
	else
		status="Error: $response"
	fi

	echo "$address:$response"
	echo "* [$pro$address $address] ($status)" >> $output
done
