#!/bin/bash

startdir=`pwd`
mkdir fasc.analysis
for x in output*; do
	cp ${x}/repacked/repacked.fasc fasc.analysis/${x}.fasc
done
cd fasc.analysis
for x in *fasc; do
	cat $x | tr -s ' ' | cut -d' ' -f 2,33 | sort -nk 2,2 > ${x}.temp
done
for x in *temp; do
	paste $x out.fasc >> out.fasc
done

