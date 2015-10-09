#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

file="$DIR/map.txt"

> "$file"
cat "$DIR/parts/template_part1.txt" >> "$file"
bash "$DIR/parts/generate_part2.sh" >> "$file"
bash "$DIR/parts/generate_part3.sh" >> "$file"
