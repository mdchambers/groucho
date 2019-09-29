# Groucho Scripts & Analysis Tools

Most tools are documented in source. Select tools are documented below

Tools are split into three broad categories:

## /chip

Tools for dealing with ChIP-chip and ChIP-seq data

## /pdb

Tools for dealing with representations of protein structure (.pdb files), using PyMol for visizulation and Rosetta for modification/docking/desing

* repack.sh

```
repack.sh performs a repack operation w/ local-refinement through Rosetta docking_protocol.macosgccrelase. It performes this operation for every pdb file in a directory

Options:
-o	Overwrite output pdbs.  Script will check for _0001.pdb corresponding files and skip (with a message to STDERR) if present

Output:
repack.fasc	Rosetta score file containing score data for every pdb evaluated
files		All files analyzed.
repack.log	A log of Rosettas activity
<input pdb>_0001.pdb	The repacked pdb file.
```


* rose_score.sh

```
Calculates Rosetta scores for every pdb file in a directory.

Options: 
  -i 
    Does scoring incrementally.  Is probably significantly slower, but useful for situations where analyzing a large number of files, as it allows stopping and resuming where it left off. Results are identical.

Output:	<directory name>.sc : Rosetta score file
		<directory name>.scorelog or <directoryname>.sc.log (directory) (if -i) 
      logs of Rosetta scoring
```

## /rnaseq

Tools for dealing with RNA-seq data