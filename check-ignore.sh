#!/bin/bash

domain=$1

ignore_domains="allizom|\.stage|stage\.|-stage|stage-|-cdn|-dev|\.dmz\.|sjc1\.|-phx\.|-sjc|\.brasstacks\.|-mirror|pfs2|-static|-www|-nii0|-origin|-proxy|^dm-|-mpt\.|^dev\.|mozilla\.net$|ecmascript\.org$|opentimetable\.jp$|-new\.|^m\.|-test\.|people\.mozilla\.com|people\.mozilla\.org"

ignore_domain_check=`echo $domain | grep -i -E $ignore_domains | wc -l | sed 's/ //g'`

if [ $ignore_domain_check == 0 ]; then
	echo "0"
else
	echo "1"
fi
