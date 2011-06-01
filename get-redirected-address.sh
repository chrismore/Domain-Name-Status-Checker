#!/bin/bash

pro="http"
address=$1

# Find redirected address

# Check to see if a website is just redirecting from http to https
	website_redirected=$(curl --write-out %{redirect_url} --silent --output /dev/null $pro://$address)
	if [ "https://$address/" == "$website_redirected" ]; then
		pro="https"
		# Check redirector again incase it redirects a second time (localization)
		website_redirected2=$(curl --write-out %{redirect_url} --silent --output /dev/null $website_redirected)
		if [ "$website_redirected2" == "" ]; then
			#If the website did not redirect again after switching to https, then set address_final to current address.
			address_final=$website_redirected
		else
			#If the website redirected a second time, set the address_final variable to the second redirected address.
			address_final=$website_redirected2
		fi
	else
		# website stayed http
		if [[ "$website_redirected" != "" ]]; then
			# website redirected, but stayed on the same domain. Probably l10n redirection.
			website_redirected2=$(curl --write-out %{redirect_url} --silent --output /dev/null $website_redirected)
			
			if [ "$website_redirected2" == "" ]; then
				# website did not redirect to a subdirectory.
				address_final=$website_redirected
			else
				#If the website redirected a second time, set the address_final variable to the second redirected address.
				address_final=$website_redirected2
			fi
			
		else
			address_final="$pro://$address"
		fi		
	fi
	
echo $address_final