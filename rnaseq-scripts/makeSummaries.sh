#!/usr/bin/env bash
# makeSummaries.sh
# Summarizes picard and roverlaps files
# Michael Chambers, 2015

mkdir summaries 2> /dev/null
for x in {run2,run3,run4}; do
    cd ${x}_out
    ../summarizePicard.sh *metrics > ../summaries/${x}_picard.txt
    ../summarizeRoverlaps.sh *roverlaps > ../summaries/${x}_roverlaps.txt
    cd ..
done

# To cat multiple output files together with a run column run the following

awk 'BEGIN {OFS="\t"} {print FILENAME, $0}' *picard.txt > all_picard.txt
awk 'BEGIN {OFS="\t"} {print FILENAME, $0}' *roverlaps.txt > all_roverlaps.txt