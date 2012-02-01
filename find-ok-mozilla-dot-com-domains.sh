#!/bin/bash

inputfile="output.txt"
outputfile="mozillacomok.txt"

#####

exec `cat /dev/null > $outputfile`

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

	if echo "$address" | grep -i 'mozilla.com$'; then

		if [ "$status_type" == "ok" ]; then
			echo "$address" >> $outputfile
		fi

	fi
done

