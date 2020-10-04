#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

TARGET="$1"

if [ -z $TARGET ]; then
	echo -e "Usage: enum_subdomains rootdomain.tld"
	exit
fi

echo $'subdomain' > "$TARGET.csv"
curl "https://crt.sh/?q=%.$TARGET&output=json" | jq '.[].name_value' | sed 's/\"//g' | sed 's/\*\.//g' | awk '{gsub(/\\n/,"\n")}1' | sort -u >> $TARGET.csv
curl -s "https://dns.bufferover.run/dns?q=.$TARGET" | jq -r .FDNS_A[] |cut -d ',' -f2 | sort -u >> $TARGET.csv

echo "All finished. File is written to $TARGET.csv"

# known problems
## the two curls are non deduplicated against eachother


# s/\"//g -  remove all occurances of the '"' symbol
# 's/\*\.//g' -  remove all occurances of the '*.' prefix
#  awk '{gsub(/\\n/,"\n")}1' - replaces \n newline char literal with space