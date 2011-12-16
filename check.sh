#!/bin/bash

# This script takes a text input list of domains and checks their status
# The output of the script are wiki bullets
# Author: Chris More

inputfile="input.txt"
outputfile="output.txt"

#####

exec `cat /dev/null > $outputfile`
exec `rm -rf web > /dev/null`

input=`cat $inputfile`

for address in $input; do

	#sleep 2
	./check-domain.sh $address $inputfile $outputfile &

done

