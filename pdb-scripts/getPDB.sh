#!/bin/bash
USAGE='

Usage: getPDB [ -h ] pdb_id pdb_id ...

Fetches pdb files from the RCSB FTP server.

Options:
	-h	Display this message and quit.

'

while getopts "h" opt; do
	case $opt in
		h)
			echo "$USAGE" >&2
			exit 2
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			echo "$USAGE" >&2
			;;
	esac
done

for x in $@; do
	wget ftp://ftp.wwpdb.org/pub/pdb/data/structures/all/pdb/pdb${x}.ent.gz
	gunzip pdb${x}.ent.gz
	mv pdb${x}.ent ${x}.pdb
done
