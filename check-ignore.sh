#!/bin/bash

domain=$1

ignore_domains="\.start([0-9])*\.|mail\.mozillaes\.net|blog\.lizardwrangler\.com|^sjc\.|^s3\.|allizom|\.stage|stage\.|-stage|stage-|-cdn|-dev|\.dmz\.|sjc1\.|-phx\.|-sjc|\.brasstacks\.|-mirror|pfs2|-static|-www|-nii0|-origin|-proxy|^dm-|-mpt\.|^dev\.|mozilla\.net$|ecmascript\.org$|opentimetable\.jp$|-new\.|^m\.|-test\.|people\.mozilla\.com|people\.mozilla\.org|hg_trunk|outgoing\.mozilla\.org|hg\.frenchmozilla\.fr|^ns[0-3]\.|^arecibo\.|^graphite\.|events\.mozilla\-europe\.org|mana\.mozilla\.org|mozillaparty\-archive\.|fortunes\.frenchmozilla\.org"
allow_domains="viewvc\.svn"

ignore_domain_check=`echo $domain | grep -i -E $ignore_domains | wc -l | sed 's/ //g'`
allow_domain_check=`echo $domain | grep -i -E $allow_domains | wc -l | sed 's/ //g'`

if [ $allow_domain_check == 0 ]; then

	address=`./get-redirected-address.sh $domain`

	ignore_body=`curl -sk $address | grep -i -E "<h1>It works\!</h1>|<h1>Index of /</h1>|<h1>Forbidden</h1>" | wc -l | sed 's/ //g'`

	if [ $ignore_domain_check == 0 ] && [ $ignore_body == 0 ]; then
		echo "0"
	else
		echo "1"
	fi

else
	echo "0"
fi
