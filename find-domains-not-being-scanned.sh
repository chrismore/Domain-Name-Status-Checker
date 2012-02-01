#!/bin/bash

curl -s https://wiki.mozilla.org/Websites/Active_List > $1

input=$1

input=`more $input | sed 's/ /\+/g'`

for line in $input; do
	prod_url=`echo "$line" | grep -i 'Prod+URL' | wc -l | sed 's/ //g'`
	if [ "$prod_url" == "1" ]; then
		address=`echo "$line" | sed -r 's/^([^"]+)(")([^"]+)(.*)/\3/' | sed -r 's/<ul><li>\+Prod\+URL:\+//g' | sed -r 's/^([^\+]*)(.*)/\1/g' | sed -r 's/www\.//g' | sed -r 's/-$//g'`
		if [ "$address" != "" ] && [ "$address" != "<ul><li>Prod" ]; then
			domain=`echo $address | sed -r "s/^(.+\/\/)([^/]+)(.*)/\2/"`
			find=`grep -i $domain input.txt | wc -l | sed 's/ //g'`
			if [ $find == 0 ]; then
				echo "$domain"
			fi
		fi
	fi
done
