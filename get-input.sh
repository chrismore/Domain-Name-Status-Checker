#!/bin/bash

output="input.txt"

exec `curl -ks https://wiki.mozilla.org/Websites/Domain_List/http | grep -i "</li><li>" | sed -r "s/<\/li><li> //g" > $output`
