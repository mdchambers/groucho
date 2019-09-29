#!/bin/bash
USAGE='translatePDBOverRange.sh [ -i increment -p posStop -n negStop] x y z pdbfile'

inc=1
pos=100
neg=100
opti=false
while getopts "i:p:n:" flag; do
	case $flag in
		i) inc=$OPTARG;;
		p) pos=$OPTARG;;
		n) neg=$OPTARG;;
	esac
done

shift $(($OPTIND -1))

if [ $# -ne 4 ]; then
	echo $USAGE
	exit 1
fi

x=$1
y=$2
z=$3
pdb=$4
num=`echo "($pos - $neg)/$inc)" | bc -q`
echo $num
for t in `jot $neg $pos $inc`; do
	tx=$(($t*$x))
	ty=$(( $t * $y ))
	tz=$(( $t * $z ))

	out=${pdb//.pdb/${t}.pdb}
	echo "Translating $pdb by $tx $ty ${tz}. Output: $out"
	convpdb.pl -translate $tx $ty $tz -chain A $pdb | grep -v "END" | sed "s/HSD/HIS/" > $out
	cat $pdb | grep " B " >> $out
done
