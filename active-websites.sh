#!/bin/bash

address=$1
output=$2

domain=`echo $address | sed -E "s/^(.+\/\/)([^/]+)(.*)/\2/"`
title=`curl -s $address | grep -i "title>" | sed -E "s/^[^<]+//g" | sed -E "s/<title>//g" | sed -E "s/<\/title>//g"`
found=`grep -i $domain current-websites.txt | wc -l | sed -E "s/ //g"`

if [ "$found" == "0" ]; then
	echo "== [[Websites/Template|$title]] ==
	* Prod URL:  $address
	* Stage URL: http://stage.example.com/
	* Code Repo: http://www.code-repository-url.com/
	* L10N Repo: http://www.l10n-repository-url.com/
	* Code: Language / Framework
	* Product Owner: Group; Person
	* Dev Team: Group; Person
	* QA Lead: Person
	* Team Email: team-email@example.com
	* Last reviewed: Person on mm/dd/yyyy
	
	" >> $output
fi