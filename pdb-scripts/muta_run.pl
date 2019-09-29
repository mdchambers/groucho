#!/usr/bin/perl
use strict;
use File::Copy;
use Cwd;
#use File::Move;
my $usage = "muta_run.pl <mutations> <positions> pdbfile\n";
my $pymoldir = "~/scripts";
my $startDir = cwd();
if ( $#ARGV != 2 ){
	print $usage;
	exit;
}
my $tm = shift @ARGV;
my $tp = shift @ARGV;
my $pdb = shift @ARGV;
my $basepdb = $pdb;
$basepdb =~ s/.pdb//;
my %aa = (
	'A' => 'ALA',
	'I' => 'ILE',
	'L' => 'LEU',
	'M' => 'MET',
	'F' => 'PHE',
	'W' => 'TRP',
	'Y' => 'TRY',
	'V' => 'VAL',
	'P' => 'PRO',
	'R' => 'ARG'
);


my @mutaOne = split( //, $tm);
my @pos = split(/,/, $tp);

sub oneToThreeAA{
	return $aa{shift @_};
}


for my $m (@mutaOne){
	for my $p (@pos){
		print "Performing $m mutation at position $p in $pdb\n";
		my $d = $basepdb . "." . $p . $m;
		#Flags for skipping various steps of progress i.e. if script was previously halted
		
		my $skipMutation = 0;
		#Check if directory already exists, and if run has been completed within
		if ( -d $d ){
			chdir($d) or die;
			if ( -e "${basepdb}_m.pdb" ){
				$skipMutation = 1;
				print "Skipping mutation.\n";
			}
		}else{	
			mkdir $d; 
			chdir($d) or die;
		}

		copy("../" . $pdb, $pdb);
		
		#Command to mutate residues using pymol and mutate.py script
		my $mutcommand = "pymol -qc ${pymoldir}/mutate.py " . $basepdb . " A/" . $p . "/ " . &oneToThreeAA($m);
		
		my $resultPDB = $basepdb . "_m.pdb";
		my $mutantPDB = $basepdb . $p . $m . ".pdb";
		unless ($skipMutation){
			print "PERFORMING: $mutcommand\n";
			`$mutcommand`;
			print "moving $resultPDB to $mutantPDB\n";
			move($resultPDB, $mutantPDB);
		}
		system("translatePDBOverRangeCM.pl", "-i", "0.2", "-n", "-10", "-p", "10", "A", "B", $mutantPDB);

		if( -e "../flags"){
			copy("../flags", "flags");
		}
		
		system("repack.sh");
		
		chdir("repacked") or die $!;
		
		system("rose_score.sh");
		chdir($startDir);
	}
}
