#!/bin/bash

outputdir="web"
address=$1
domain=`echo $address | sed -r "s/^(.+\/\/)([^/]+)(.*)/\2/"`

exec `wget -D $domain -R .swf,.JPG,.PNG,.GIF,.tiff,.bmp,*smartproxy*,.ppt,.ics,.gz,.xpi,.pdf,.exe,.rss,.js,.png,.css,.gif,.jpg,.ico,.flv,.dmg,.zip,.txt -r -q -l 5 -nc --connect-timeout=5 -Q 100m -P$outputdir --no-check-certificate --html-extension -U "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0.1) Gecko/20100101 Firefox/9.0.1" $address` 

# Grep for the number of pages that include the analytics string - stop at first occourance of string in file

files=`grep -lrie "src=\"http://" ./web/$domain --include=*.html`

echo $files > output-http-items.txt

#exec `rm -rf $outputdir/$domain`
