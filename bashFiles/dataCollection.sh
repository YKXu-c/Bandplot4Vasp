#!/bin/bash
energyLowpress=energyLowpress_test
dosband=./dosband/
efermi=efermi_test
for file in $(find . -maxdepth 1 -type d | sort -n); do
	if [ "$file" != "./saveScripts" ]; then
	echo -n "$file" >> ${energyLowpress}
	echo -n " " >> ${energyLowpress}
	awk '/energy without/ {if (match($0, /\-+[0-9]+(\.[0-9]+)?/)) {last_line=substr($0, RSTART, RLENGTH)}} END {print last_line}' $file/OUTCAR >> ${energyLowpress}	
	sed -i 's/^[\/]*//' ${energyLowpress}
	sed -i 's/^[^a-zA-Z]*//' ${energyLowpress}
	fi
done