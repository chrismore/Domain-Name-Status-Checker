#!/bin/bash

inputfile="input-directory.txt"
outputfile="output-directory.txt"
cat output-prod.txt | sed -r 's/[\* ]+//' > $inputfile
exec `sort -o $inputfile $inputfile`
exec `cat /dev/null > $outputfile`

input=`cat $inputfile`

previousletter="0"

echo "<div>" >> $outputfile
for address in $input; do
echo "index: $address"

	check_old=`./check-old.sh $address`

	title=`exec ./get-title.sh $address`

	if [ "$check_old" == "0" ] && [ "$title" != "" ]; then

	        letter=`echo $address | cut -c 1 | tr '[:lower:]' '[:upper:]'`

	        if [ $letter != $previousletter ]; then

	                echo "<a href="#$letter">$letter</a> |" >> $outputfile

	                previousletter=$letter
        	fi

	fi

done
echo "</div>" >> $outputfile

previousletter="0"

echo "<div>" >>	$outputfile
for address in $input; do

echo "site: $address"

	check_old=`./check-old.sh $address`

        if [ "$check_old" == "0" ]; then

		letter=`echo $address | cut -c 1 | tr '[:lower:]' '[:upper:]'`

		if [ $letter != $previousletter ]; then
		
			if [ $previousletter != "0" ]; then
				echo "</ul>" >> $outputfile
			fi

			echo "<h2 id=\"$letter\">$letter</h2><ul>" >> $outputfile

			previousletter=$letter		
		fi

		title=`exec ./get-title.sh $address`

		check_dup=`grep " - $title<" $outputfile | wc -l | sed 's/ //g'`

		if [ "$title" != "" ] && [ $check_dup == "0" ]; then
			echo "<li><a href=\"http://$address\">$address</a> - $title</li>" >> $outputfile
		else
			echo "Opps! title=$title dup=$check_dup"
		fi

	else

		echo "Old: $address"

	fi

done
echo "</div>" >> $outputfile
echo "done"
