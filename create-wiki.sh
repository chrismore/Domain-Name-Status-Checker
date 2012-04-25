#!/bin/bash

inputfile="output.txt"
check_active_websites=0

output="output-wiki.txt"
output_ok="output-ok.txt"
output_http="output-http.txt"
output_ftp="output-ftp.txt"
output_robots="output-robots.txt"
output_websites="active-websites.txt"
output_prod="output-prod.txt"
output_prod_analytics="output-prod-analytics.txt"
output_owned="output-owned.txt"
output_not_owned="output-not-owned.txt"
output_prod_owned="output-prod-owned.txt"
output_prod_old="output-prod-old.txt"
output_prod_owned_root_domains="output-prod-owned-root-domains.txt"

input_wiki="current-websites.txt"
exec `sort -o $inputfile $inputfile`

exec `cat /dev/null > $output`
exec `cat /dev/null > $output_ok`
exec `cat /dev/null > $output_http`
exec `cat /dev/null > $output_ftp`
exec `cat /dev/null > $output_robots`
exec `cat /dev/null > $output_websites`
exec `cat /dev/null > $output_prod`
exec `cat /dev/null > $output_prod_analytics`
exec `cat /dev/null > $output_owned`
exec `cat /dev/null > $output_not_owned`
exec `cat /dev/null > $output_prod_owned`
exec `cat /dev/null > $output_prod_old`
exec `cat /dev/null > $output_prod_owned_root_domains`

total_websites=0
total_analytics=0
total_ok=0
total_error=0
total_redirect=0
total_ftp=0
total_robots_blocked=0
total_prod=0
total_owned=0
total_not_owned=0
total_prod_owned=0
total_prod_old=0
total_prod_owned_root_domains=0

if [ $check_active_websites == 1 ]; then
	curl -ks https://wiki.mozilla.org/Websites/Active_List > $input_wiki
fi

today=`date +%m-%d-%Y`

echo "The following is a list of active websites that are blocked from ALL robot spidering:
" > $output_robots

echo "__TOC__

== Domain List ==

The following list and updates is as of $today.

	{| class='wikitable sortable' border='1'
	|-
	! scope='col' | Web Address
	! scope='col' | Status
	! scope='col' | Analytics Installed
	! scope='col' | Analytics Page Coverage
	! scope='col' | Mozilla Owned" > $output

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
	owned=$7

	echo $address

	echo "|-" >> $output 

	if [ "$status_type" == "ok" ]; then
		(( total_ok++ ))
		robots=`./check-robots.sh $address`
		if [ "$robots" == "1" ]; then
			(( total_robots_blocked++ ))
			echo "* [$pro://$address $address]" >> $output_robots
		fi

		ignore_domain_check=`./check-ignore.sh $address`		

		if [ $ignore_domain_check == 0 ]; then
			(( total_prod++ ))
			echo "* $address" >> $output_prod
			if [ $owned == "Yes" ]; then
				echo "* $address" >> $output_prod_owned
				(( total_prod_owned++ ))
				root_domain=`./get-root-domain.sh $address`
				root_exists=`grep -i $root_domain $output_prod_owned_root_domains | wc -l | sed 's/ //g'`

				if [ $root_exists == "0" ]; then
					echo "* $root_domain" >> $output_prod_owned_root_domains
					(( total_prod_owned_root_domains++ ))
				fi

			fi

                	check_old=`./check-old.sh $address`

		        if [ $check_old == "1" ]; then
                	       (( total_prod_old++ ))
                        	echo "* $address" >> $output_prod_old
        		fi

		fi

		if [ $check_active_websites == 1 ]; then

			address_check=`./get-redirected-address.sh $address`
			echo "Check: $address, $address_check"
			exec `./active-websites.sh $address_check $input_wiki $output_websites > /dev/null`

		fi

		echo "* $address" >> $output_ok


	elif [ "$status_type" == "error" ]; then
		(( total_error++ ))
	elif [ "$status_type" == "redirect" ]; then
		(( total_redirect++ ))
	fi
	
	if [[ "$pro" == "ftp" ]]; then
		(( total_ftp++ ))
		echo "* $address" >> $output_ftp
	else
		(( total_websites++ ))
		echo "* $address" >> $output_http
	fi
	
	if [ "$analytics" == "Yes" ] && [ $ignore_domain_check == 0 ]; then
		(( total_analytics++ ))
		echo "* $address" >> $output_prod_analytics
	fi
	
	if [ "$coverage" != "N/A" ]; then
		coverage="$coverage%"
	fi

	if [ "$owned" == "Yes" ]; then
		(( total_owned++ ))
		echo "* $address" >> $output_owned
	fi

	if [ "$owned" == "No" ]; then
		(( total_not_owned++ ))
		echo "* $address" >> $output_not_owned
	fi
	
	echo "| [$pro://$address $address] || $status || $analytics || $coverage || $owned" >> $output

done

echo "|}

== Statistics ==

* Total domains: [[Websites/Domain_List/http|$total_websites]]
* Total ok: [[Websites/Domain_List/ok|$total_ok]]
* Total production: [[Websites/Domain_List/prod|$total_prod]]
* Total errors: $total_error
* Total redirects: $total_redirect
* Total prod analytics installed: [[Websites/Domain_List/prod-analytics|$total_analytics]]
* Total robot blocked websites: [[Websites/Domain_List/robots-blocked|$total_robots_blocked]]
* Total Mozilla owned: [[Websites/Domain_List/Mozilla_Owned|$total_owned]]
* Total Mozilla production owned: [[Websites/Domain_List/Mozilla_Prod_Owned|$total_prod_owned]]
* Total Mozilla production owned root domains: [[Websites/Domain_List/Mozilla_Prod_Owned_Root_Domains|$total_prod_owned_root_domains]]
* Total community owned: [[Websites/Domain_List/Community_Owned|$total_not_owned]]
* Total production old homepage: [[Websites/Domain_List/Production_Old|$total_prod_old]]

== Do you have changes to this list? ==

This wiki page is automatically generated by scripts. Please contact [https://ldap.mozilla.org/phonebook/tree.php#search/cmore@mozilla.com Chris More] for more 
information. The source script for this page can be found [https://github.com/chrismore/Domain-Name-Status-Checker here]." >> $output

exec `sort -o $output_prod_owned_root_domains $output_prod_owned_root_domains`
echo "Done."
