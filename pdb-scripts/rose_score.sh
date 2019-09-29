 #/bin/bash
USAGE='rose_score.sh [-i]

Calculates Rosetta scores for every pdb file in a directory.

Options: -i Does scoring incrementally.  Is probably significantly slower, but useful for situations where analyzing a large number of files,
as it allows stopping and resuming where it left off. Results are identical.

Output:	<directory name>.sc : Rosetta score file
		<directory name>.scorelog or <directoryn ame>.sc.log (directory) (if -i) logs of Rosetta scoring'

function myHelp {
	echo "$USAGE"
	exit 1;
}

base=`basename $(pwd)`
output=${base}.fasc
log=${base}.scorelog
pdbfilestemp=${base}.allfiles

targs=''
for p in "$@"; do
	if [ "$p" = "--help" ]; then
		myHelp;
	fi
done

opt_i=false;
opt_a=false;
while getopts "i" flag; do
	case $flag in
		i) opt_i=true;;
	esac
done

function myHelp {
	echo $USAGE
	exit 1;
}

function proceedContinue {
	for x in *pdb; do
		bp=${x//.pdb/}
		if [ `grep $x $output | wc -m` > 1 ]; then
			echo $x "already present... skipping..."
		else
			echo "Adding " $x '...'
			echo $x >> $pdbfilestemp
		fi
	done
	#score.macosgccrelease -out:file:scorefile $output -database ~/rosetta/rosetta_database/ -in:file:l $pdbfilestemp > $log;
	exit 0
}

function proceedAll {
	ls *.pdb > $pdbfilestemp
	numfiles=`wc -l $pdbfilestemp`
	echo "Rosetta scoring " $numfiles " structures."
	score.macosgccrelease -out:file:scorefile $output -database ~/rosetta/rosetta_database/ -in:file:l $pdbfilestemp > $log;
	rm $pdbfilestemp
}


function proceedIncrement {
	for x in *pdb; do
		if [ -e ${x}.log ]; then
			echo "Skipping ${x}"
			continue
		fi
		echo "Scoring $x"
		score.macosgccrelease -s $x -out:file:scorefile ${x}.temp -database ~/rosetta/rosetta_database/ > ${x}.t;
		mv ${x}.t ${x}.log
		if [ ! -e $output ]; then
			head -1 $x.temp > $output
		fi
	done
	
	mkdir ${output}.logs
	for x in *temp; do
		cat $x | grep -v "score" >> $output;
		mv ${x//temp/log} ${output}.logs/${x//temp/log}
	done
	
	rm *temp;
}

echo "Writing to ${output}..."
if [ -e $output ]; then
	echo "Output file already present…"
	echo "Backing up " $output " and scoring remaining files…"
	cp $output ${output}.bak
	proceedContinue
fi

if $opt_i; then
	proceedIncrement
else
	proceedAll
fi
rm $pdbfilestemp 2> /dev/null
exit 0
