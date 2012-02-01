#!/bin/bash

cat current-websites-wiki.txt | sed -r "s/( )*(==)( )*/\2/g" | sed -r "s/(==\[\[?|\]\]?==)/==/g" | sed -r "s/==([^\|]+\|)?/==/g" | sed ':a;N;$!ba;s/\n//g' | sed -r "s/==([^*])/\n==\1/g" > temp.txt
sort temp.txt | sed -r "s/==\*/==\n\*/g" | sed -r "s/\*/\n\*/g" | sed -r "s/^==/\n==/g" | sed -r "s/^==/==\[\[/g" | sed -r "s/==$/\]\]==/g" > current-websites-wiki-sorted.txt
