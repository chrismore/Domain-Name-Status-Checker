#!/bin/bash

inputfile="output.txt"
output="output-wiki.txt"
output_robots="output-robots.txt"
exec `sort -o $inputfile $inputfile`
exec `cat /dev/null > $output`

total_websites=0
total_analytics=0
total_ok=0
total_error=0
total_redirect=0
total_ftp=0
total_robots_blocked=0

today=`date +%m-%d-%Y`

echo "The following is a list of active websites that are blocked from ALL robot spidering:
" > $output_robots

echo "The following list and updates is as of $today.

	{| class='wikitable sortable' border='1'
	|-
	! scope='col' | Web Address
	! scope='col' | Status
	! scope='col' | Analytics Installed
	! scope='col' | Analytics Page Coverage" > $output

input=`cat $inputfile`

for thisline in $input; do
	
	IFS=","
	var=$thisline
	set -- $var
	
	address=$1
	pro=$2
	status=`echo $3 | sed 's/\+/ /g'` 
	status_type=$4
	analytics=$5
	coverage=$6

	echo "|-" >> $output 

	if [ "$status_type" == "ok" ]; then
		(( total_ok++ ))
		robots=`./check-robots.sh $address`
		if [ "$robots" == "1" ]; then
			(( total_robots_blocked++ ))
			echo "* [[$pro:$address/robots.txt|$address]]" >> $output_robots
		fi
	elif [ "$status_type" == "error" ]; then
		(( total_error++ ))
	elif [ "$status_type" == "redirect" ]; then
		(( total_redirect++ ))
	fi
	
	if [[ "$pro" == "ftp" ]]; then
		(( total_ftp++ ))
	else
		(( total_websites++ ))
	fi
	
	if [ "$analytics" == "Yes" ]; then
		(( total_analytics++ ))
	fi
	
	if [ "$coverage" != "N/A" ]; then
		coverage="$coverage%"
	fi
	
	echo "| [$pro://$address $address] || $status || $analytics || $coverage" >> $output

done

echo "|}

== Statistics ==

* Total websites: [[Domain Names/all|$total_websites]]
* Total FTP servers: $total_ftp
* Total ok: $total_ok
* Total errors: $total_error
* Total redirects: $total_redirect
* Total analytics installed: $total_analytics
* Total robot blocked websites: [[Domain Names/robots-blocked|$total_robots_blocked]]

The source script for this page can be found [https://github.com/chrismore/Domain-Name-Status-Checker here]." >> $output