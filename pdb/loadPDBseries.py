from glob import glob
from os.path import sep, basename
import sys
 
def loadDir(start, end="0", dirname="."):
        """
	Loads all files in a series; series are numbered START.pdb to END.pdb (e.g. 0000.pdb - 1000.pdb)
 
        dirName:        directory path
	start:		starting structure number
	end:		ending structure number
 
        example:
                # load all the PDBs in the current directory
                loadDir
 
                # load 0000.pdb - 0500.pdb files from /tmp
                loadDir /tmp, 0, 500
        """
 
	if start > end:
#print usage
		return
	if end == 0:
		fpath = dirName + sep + "*_" + start + "*pdb"
		f = glob(fpath)
		while(f != None):
#cmd.load(f)
			print "Loading %s" % f
			start += 1
			fpath = dirName + sep + "*_" + start + "*pdb"
		return
	else
		for i in range(start, end + 1 ):
			fpath = dirName + sep + "*_" + i + "*pdb"
			f = glob(fpath)
#cmd.load(f)
			print "2Loading %s" % f

 
#cmd.extend("loadDir", loadDir)
def main():
	loadDir(args[0], args[1])

def loadRange(start, end=0):
	for i in range(start, end):
		path
        for c in glob( g ):
                cmd.load(c)
 
                if ( group != None ):
                        cmd.group( group, basename(c).split(".")[0], "add" )
	return 

if __name__ == "__main__":
	sys.exit(main())
