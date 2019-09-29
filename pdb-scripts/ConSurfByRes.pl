#!/usr/bin/perl -w
use strict;
my $USAGE = "ConSurfByRes.pl <consurf pdb> <pdb to add scores to>\nCopies ConSurf conservation scores from one PDB file to another by residue.  Residue numbers must correspond, though chains need not. Residues in the annotated file withoutscores in the input pdb will have no score.\n";

if($#ARGV != 1){
	print STDERR $USAGE . "\n";
	exit;
}
my $f1 = shift;
my $f2 = shift;
open INF, "< $f1";
open MODF, "< $f2";

my $current_res= 0;
my $res_score = '';
my %res_s;
while(<INF>){
	next unless /^ATOM/;
	
	my @line = split;
	
	if($current_res == 0){
		$current_res = $line[5];
		$res_score = $line[10];
		$res_s{$current_res} = $res_score;
	}
	if($line[5] != $current_res){
		$current_res = $line[5];
		$res_score = $line[10];
		$res_s{$current_res} = $res_score;
	}
}

while(<MODF>){
	if(/^ATOM/){
		chomp;
		print $_ . "     ";
		my @line = split;
		print $res_s{$line[5]} if exists $res_s{$line[5]};
		print "\n";
	}else{
		print;
	}
}
		
	
