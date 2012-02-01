#!/bin/bash

curl -s https://wiki.mozilla.org/Websites/Active_List > active_list.txt

input=`more active_list.txt | sed 's/ /\+/g'`
output_ok="active_list_ok.txt"
output_error="active_list_error.txt"
output_active_list="output-active-list-wiki.txt"

exec `cat /dev/null > $output_ok`
exec `cat /dev/null > $output_error`
exec `cat /dev/null > $output_active_list`

for line in $input; do
	prod_url=`echo "$line" | grep -i 'Prod+URL' | wc -l | sed 's/ //g'`
	if [ "$prod_url" == "1" ]; then
		address=`echo "$line" | sed -r 's/^([^"]+)(")([^"]+)(.*)/\3/' | sed -r 's/<ul><li>\+Prod\+URL:\+//g' | sed -r 's/^([^\+]*)(.*)/\1/g' | sed -r 's/www\.//g' | sed -r 's/-$//g'`
		if [ "$address" != "" ] && [ "$address" != "<ul><li>Prod" ]; then
			domain=`echo $address | sed -r "s/^(.+\/\/)([^/]+)(.*)/\2/"`

			response=$(curl --write-out %{http_code} --silent --output /dev/null $address)        
			if [ $response == "200" ] || [ $response == "226" ]; then
				status_type="ok"
			elif [ $response == "301" ] || [ $response == "302" ]; then
				address_redirected=$(curl --write-out %{url_effective} --silent --output /dev/null -L $address)
				domain_redirected=`echo $address_redirected | sed -r "s/^(.+\/\/)([^/]+)(.*)/\2/"`
				if [ $domain == $domain_redirected ] || [ $domain_redirected == "www.$domain" ]; then
					status_type="ok"
				else
		             		status_type="redirect"
				fi
			elif [ $response == "000" ]; then
				response=$(curl --write-out %{http_code} --silent --output /dev/null www.$domain)
				if [ $response == "200" ]; then
					status_type="ok"
				else
					status_type="timeout"
				fi
			else
				status_type="error"
			fi

			check_owned=`./check-owned.sh $domain`

		        if [ "$check_owned" == "1" ]; then
               			owned="Yes"
        		else
            			owned="No"
        		fi
			
			echo "$address: $response"

			if [ $status_type == "ok" ] && [ $owned == "Yes" ]; then
				echo "$domain" >> $output_ok
				exec `./active-websites.sh $address active_list.txt $output_active_list > /dev/null`
			else
				echo "$domain, status_type=$status_type, response=$response, owned=$owned" >> $output_error							
			fi
		fi
	fi
done
