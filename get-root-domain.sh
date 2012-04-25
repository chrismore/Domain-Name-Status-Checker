#!/bin/bash

domain=$1

root=`echo $domain | sed -r "s/(.+)\.(.+)\.([^\.]+)$/\2.\3/g"`

if [ $root == "org.uk" ]; then

	root=`echo $domain | sed -r "s/(.+)\.(.+)\.(.+)\.([^\.]+)$/\2.\3.\4/g"`
fi

echo $root
