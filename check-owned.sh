#!/bin/bash

address=$1
domain=`echo $address | sed -r "s/^(.+\/\/)([^/]+)(.*)/\2/"`

input=`cat name-servers.txt`
auth=0

for nameserver in $input; do
	query=`nslookup -timeout=1 $domain $nameserver`
	not_authoritative=`echo $query | grep -i -E "(Non-authoritative answer|server can't find|connection timed out)" | wc -l | sed 's/ //g'`
	if [ $not_authoritative == 0 ]; then
		(( auth++ ))
	fi
done
if [ $auth == 0 ]; then
	echo 0
else
	echo 1
fi
