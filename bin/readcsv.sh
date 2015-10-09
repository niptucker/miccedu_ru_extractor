#!/bin/bash

while IFS=$'\t'  read col1 col2
do
    echo "I got:$col1|$col2"
done < <(cat ../conf/map.txt | sed ':a;N;$!ba;s/\n/\t/g' | sed 's:\t\t:\n:g')

