#!/bin/bash

address=$1
input=$2
output=$3

domain=`echo $address | sed -r "s/^(.+\/\/)([^/]+)(.*)/\2/"`
title=`curl -s $address | grep -i "title>" | sed -r "s/^[^<]+//g" | sed -r "s/<title>//g" | sed -r "s/<\/title>//g" | sed -r "s/\n|\t//g"`
found=`grep -i $domain $input | wc -l | sed -r "s/ //g"`

if [ "$found" == "0" ]; then

echo "== [[Websites/Template|$title]] ==
* Prod URL:  $address
* Stage URL: http://stage.example.com/
* Code Repo: http://www.code-repository-url.com/
* L10N Repo: http://www.l10n-repository-url.com/
* Code: Language / Framework
* Licensing:
* Product Owner: Group; Person
* Dev Team: Group; Person
* QA Lead: Person
* Team Email: team-email@example.com
* Last reviewed: Person on mm/dd/yyyy

" >> $output
fi
