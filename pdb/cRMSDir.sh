#!/bin/bash
opt_n=false
opt_c=false
while getopts "nc" flag; do
	case $flag in
		n) opt_n=true;;
		c) opt_c=true;;
	esac
done 

shift $((OPTIND -1))

if [ $# -ne 1 ]; then
	echo "cRMSDir.sh <comparison pdb>"
	echo "cRMSDir.sh first cleans pdb files (renumber/rechain) using pdbchain.pl. It takes these clean pdb's (.cdb) files and calculates a per-chain detailed by atom and residue type RMSD using rms.pl (from MMSTP package)."
	echo "Output: Multiple .rms files (one per input .pdb in a subdirectory cleanpdbs"
	exit;
fi

first=$1
cfirst=${first//pdb/cdb}
echo "Comparison pdb: $cfirst";
mkdir cleanpdbs
for x in *pdb; do
	if $opt_n && $opt_c; then 	pdbchain.pl -nc $x > cleanpdbs/${x//pdb/cdb};
	elif $opt_n; then pdbchain.pl -n $x > cleanpdbs/${x//pdb/cdb};
	elif $opt_c; then pdbchain.pl -c $x > cleanpdbs/${x//pdb/cdb};
	else pdbchain.pl $x > cleanpdbs/${x//pdb/cdb}; fi
done

cd cleanpdbs

for x in *cdb; do
	echo "Doing $cfirst vs. $x"
	rms.pl -detailed -chains -resnumonly $cfirst $x > ${x//cdb/rms};
done
cd ..
