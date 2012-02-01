#!/bin/bash

inputfile="community-websites.txt"
checkfile="input.txt"
output="input-community-websites.txt"
#####

exec `cat /dev/null > $output`

input=`cat $inputfile`

for address in $input; do

	missing=0

	found=`grep -iE "^\$address$" $checkfile`

	if [ "$found" == "" ]; then
		#address is not in the master input.txt file

		missing=1
		address_missing=$address
	else
		missing=0
	fi


	address_www="www.$address"
        found=`grep -iE "^\$address_www$" $checkfile`
        if [ "$found" != "" ]; then
		echo "found $address_www"
	    	# found www prefixed to the domain, so it 
		missing=0
		address_missing=$address_www
	fi

	if [ $missing == 1 ]; then
		echo $address_missing >> $output
	fi

done

