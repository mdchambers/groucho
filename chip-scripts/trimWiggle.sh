#!/usr/bin/env bash
USAGE='
Usage: trimWiggle [ -h ] chromosome_size_file wiggle_file

Trims a wiggle file:
    Positions < 0 are adjusted to 0
    Positions > chromosome length are adjusted to that value

Writes to STDOU

Michael Chambers, 2014
'

while getopts "h" opt; do
    case $opt in
        h)
            echo "$USAGE" >&2
            exit
            ;;
        \?)
            echo "Flag not recognized: " >&2
            echo "$USAGE" >&2
            exit 2
            ;;
    esac
done

chrom_file=$1
wig_file=$2

awk -v CHR=$chrom_file '
    BEGIN {
        OFS=" "
        while(getline < CHR){
            chrsize[$1] = $2
        }
    }
    /track/ { print $0; next;}
    {
        chr = $1
        start = $2
        end = $3
        value = $4
        if ( start < 0){
            start = 0
        }
        if( end > chrsize[$1]){
            end = chrsize[$1]
        }
        print chr, start, end, value
    }' $wig_file