#!/bin/bash

first=$1
echo "Comparison cdb: $first";

for x in *cdb; do
	echo "Doing $first vs. $x"
	rms.pl -detailed -chains -resnumonly $first $x > ${x//cdb/rms};
done
