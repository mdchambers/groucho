#!/bin/bash
echo "PDB	c.A	c.B"
for x in *rms; do
	cat $x | grep "back" | tr -s ' ' | cut -d' ' -f 3 > t;
	echo -n "${x//.rms/}	"
 	head -1 t | tr -d '\n'
	echo -n "	"
	tail -1 t
	rm t
done