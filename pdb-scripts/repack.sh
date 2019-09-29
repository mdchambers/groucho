#!/bin/bash
USAGE='repack.sh [ -o ]

repack.sh performs a repack operation w/ local-refinement through Rosetta docking_protocol.macosgccrelase. It performes this operation for every pdb file in a directory

Options:
-o	Overwrite output pdbs.  Script will check for _0001.pdb corresponding files and skip (with a message to STDERR) if present

Output:
repack.fasc	Rosetta score file containing score data for every pdb evaluated
files		All files analyzed.
repack.log	A log of Rosettas activity
<input pdb>_0001.pdb	The repacked pdb file.
'
echo -n '' > files

for p in $@; do
	if [ $p = '--help' ]; then
		echo "$USAGE"
		exit 1
	fi
done

overwrite=false;
while getopts "o" flag; do
	case flag in
		o) overwrite=true;;
	esac
done
if $overwrite; then
	for x in *pdb; do
		echo $x >> file
	done
elif [ -d repacked ]; then
	for x in *pdb; do
		if [ -e ${x//.pdb/_0001.pdb} ] || [ -e repacked/${x//.pdb/_0001.pdb} ]; then
			echo "Skipping ${x}..."
		else
			echo $x >> files
		fi
	done
else
	for x in *pdb; do
		if [ -e ${x//.pdb/_0001.pdb} ]; then
			echo "Skipping ${x}..."
		else
			echo $x >> files
		fi
	done
fi
cat files | grep -v "0001" > files.2
mv files.2 files
echo -n "Starting docking on "
fx=`wc -l files`
echo -n $fx
echo " structures."
if [ -e flags ]; then
	docking_protocol.macosgccrelease @flags -out:file:o repack -in:file:l files >> repack.log
else
	docking_protocol.macosgccrelease -docking_local_refine -partners A_B -database /Users/mike/rosetta/rosetta_database -nstruct 1 -mute core.util.prof -out:file:o repack -in:file:l files >> repack.log
fi

mkdir repacked 2> /dev/null
mv *0001.pdb repacked/ 2> /dev/null
#rm files
exit 0
