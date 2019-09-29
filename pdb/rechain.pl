#!/usr/bin/env perl
use strict;
use Getopt::Std;
my $USAGE ='
Usage: rechain.pl  -h pdb_file

Resets chains of a PDB file to A, B, C, etc.
Writes to stdout

Michael Chambers, 2012
';

our($opt_h);
getopts('h');
&usage if($opt_h);
&usage if($#ARGV < 0);

my $fname = shift @ARGV;
open FILE, "< $fname";
#open DEBUG, "> dbug.rechain";
my @pdb;

push @pdb, $_ for(<FILE>);
my $modelflag = 0;

my $chain = 64;
my $current;
for(@pdb){
	if(/^MODEL/){
		$chain++;
		$current = $chain;
#		printf DEBUG "in model w/ %s %s\n", chr $chain, chr $current;
		$modelflag++;
		next;
	}
	if(/^TER/){
		$chain++;
		$current = $chain;
		$modelflag++;
		next;
	}
	if(/^ATOM/){
		if( ! defined($current)){
			$current =ord( substr($_, 21, 1) );
			$chain = $current;
		}
		if( chr($current) ne substr($_, 21, 1)){
			$chain++;
			$chain-- if($modelflag);
			$modelflag = 0;
			$current = ord (substr($_, 21, 1));
#			printf DEBUG "in atomswitch w/ %s %s %s\n", chr $chain, chr $current, substr($_, 21, 1);
			substr $_, 21, 1, chr($chain);
			print;
			
			next;
		}else{
#			printf DEBUG "in atom w/ %s %s %s\n", chr $chain, chr $current, substr($_, 21, 1);
			substr $_, 21, 1, chr($chain);
			$modelflag = 0;
			print;
		}
	}
}

sub usage{
	print STDERR $USAGE;
	exit 2;
}




		



#for (@pdb){
#	if(/^ATOM/){
#		$start = substr $_, 21, 1;
#		
#for (@pdb){
#	$current = substr $_, 21, 1 if(/^ATOM/);
#	$chain++ if(/^MODEL/);
#	$chain++ if(
#	
#	if(/^MODEL/){
#		$chain++;
#		$flag = 0;
#	}
#	if (/^ATOM/){
#		if((chr($chain) ne (substr $_, 21, 1))){
#			$chain++;
#			$flag = 1;
#		}
#		$c =  substr $_, 21, 1, chr($chain);
#		print $_;
#		
#	}
#	
#}
