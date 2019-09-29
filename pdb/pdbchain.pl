#!/usr/bin/perl
use strict;

use Getopt::Std;
$Getopt::Std::STANDARD_HELP_VERSION = 1;

our ($opt_n, $opt_c);
my ($rechain, $renumber);
getopts('nc');

sub VERSION_MESSAGE {
	my $fh = shift; 
	print $fh "pdbchain.pl v1.0\n";
}

sub HELP_MESSAGE {
	my $fh = shift;
	print $fh "Usage: pdbchain.pl [-nc] <pdb file>\n";
	print $fh "pdbchain.pl takes a pdb file and reformats the line number, chain, and residue number to conform to pdb standards.\n";
	print $fh "Options: -n Renumbers residues on each chain from 1\n";
	print $fh "         -c Designates chains starting from A \(ie\. A, B, C \.\.\.\)\n";
	print $fh "In all cases, the line numbers are formatted. Additionally, TER lines are added at the end of each chain.\n";
}


#Check to renumber lines
if($opt_n){
	$renumber = 1;
}
#Check to rechain lines
if($opt_c){
	$rechain = 1;
}


my $file = shift @ARGV;
open PDB, "< $file";
my @lines;

push @lines, $_ for( <PDB>);
my $index = 0;
my $atomindex = 0;
my $chain;
my @last;
for (@lines){
	my @l = split;

	if($l[0] eq "TER"){
		
		$index++;
		print "TER    $index      $last[3] $chain  $atomindex\n";


	}
	if($l[0] eq "ATOM"){
		$index++;
		#First atom line condition
		if( ! defined($chain)){
			if(! $rechain){
				$chain = $l[4];
			} else {
				$chain = 'A';
			}
			if( ! $renumber ){
				$atomindex = $l[1];
			} else {
				$atomindex = 1;
			}
			
			print &makePDBline("ATOM", $index, $l[2], $l[3], $chain, $atomindex, $l[6], $l[7], $l[8], $l[9], $l[10], $l[11]);
			@last = @l;
			next;
		}
		
		#Check for space between 9 and 10 elements; correct if necessary
		if( ! defined $l[11]){
			$l[11] = $l[10];
			my $new9 = substr( $l[9], 0, 4 );
			my $new10 = substr ($l[9], 4 );
			$l[9] = $new9;
			$l[10] = $new10;
		}
		
		#Check if same chain; 
		if($l[4] eq $last[4]){
		#	$index++;
			if($l[5] ne $last[5]){
				$atomindex++
			}	
			print &makePDBline("ATOM", $index, $l[2], $l[3], $chain, $atomindex, $l[6], $l[7], $l[8], $l[9], $l[10], $l[11]);
			@last = @l;
			next;
		}
		
		#Check if different chain
		if($l[4] ne $chain){
#			$index = 1;
#			$chain++;
#			$index++;
			if($renumber){
				$atomindex = 1;
			} else {
				$atomindex = $l[5];
			}
			if($rechain){
				$chain++;
			} else {
				$chain = $l[4];
			}
			
			print &makePDBline("ATOM", $index, $l[2], $l[3], $chain, $atomindex, $l[6], $l[7], $l[8], $l[9], $l[10], $l[11]);
			@last = @l;
			next;
		}
	}
	if($l[0] eq "END"){
		print;
	}
}

sub addSpacesBefore{
	my ($s, $num) = @_;
	return sprintf("%s" x 2, ' ' x $num, $s);
}

sub fillWSpacesBefore{
	my ($s, $lengthDesired) = @_;
	return &addSpacesBefore($s, ($lengthDesired - length $s));
} 

sub addSpacesBehind{
	my ($s, $num) = @_;
	return sprintf("%s" x 2, $s, ' ' x $num);
}

sub fillWSpacesBehind{
	my ($s, $lengthDesired) = @_;
	return &addSpacesBehind($s, ($lengthDesired - length $s));
}


sub makePDBline{
	my ($nom, $line, $atom, $res, $chain, $chainLine, @positions) = @_;
	my $outstr = $nom;
	$outstr .= &fillWSpacesBefore($line, 7) . "  " . &fillWSpacesBehind($atom, 4) . $res . " " . $chain;
	$outstr .= &fillWSpacesBefore($chainLine, 4);
	$outstr .= &fillWSpacesBefore($positions[0], 12) . &fillWSpacesBefore($positions[1], 8) . &fillWSpacesBefore($positions[2], 8) .
		&fillWSpacesBefore($positions[3], 6) . &fillWSpacesBefore($positions[4], 6) . &fillWSpacesBefore($positions[5], 12) . "\n";
#	print "YO: $positions[4]\n";
#	my $x = 4 - length $atom;
#	$outstr .= &addSpaces($res, $x);
#	$x = 2;
#	$x = 1 if($chainLine > 99);
#	$outstr .= " " . $chain;
#	$outstr .= addSpaces($chainLine, $x);
#	$x = 12 - length $positions[0];
#	$outstr .= addSpaces($positions[0], $x);
#	$x = 8 - length $positions[1];
#	$outstr .= addSpaces($positions[1], $x);
#	$x = 8 - length $positions[2];
#	$outstr .= addSpaces($positions[2], $x);
#	$x = 6 - length $positions[3];
#	$outstr .= addSpaces($positions[3], $x);
#	$x = 6 - length $positions[4];
#	$outstr .= addSpaces($positions[4], $x);
#	$x = 12 - length $positions[5];
#	$outstr .= addSpaces($positions[5], $x) . "\n";
	return $outstr;
}
