#!/usr/bin/perl
use strict;
use Getopt::Std;

my $USAGE = 'translatePDBOverRange.pl [ -i increment -p posStop -n negStop] x y z pdbfile';

our($opt_i, $opt_n, $opt_p);

getopt('inp');
$opt_i = 1 if( ! defined $opt_i);
$opt_p = 100 if (! defined $opt_p);
$opt_n = 100 if (! defined $opt_n);

unless($#ARGV == 3){
	print $USAGE;
	exit;
}

my ($x, $y, $z, $pdb);

$x = shift @ARGV;
$y = shift @ARGV;
$z = shift @ARGV;
my @vec = ($x, $y, $z);
my @uvec = &makeUnitVector(@vec);
$pdb = shift @ARGV;

for(my $i = $opt_n; $i <= $opt_p; $i += $opt_i){
	my @tvec = &vectorMultiply(@uvec, $i);
#	print "i: " . $i . "\n";
#	print "OVECTOR: " . "@vec" . "\n";
#	print "UVECTOR: " . "@uvec" . "\n";
#	print "TVECTOR: " . "@tvec" . "\n";
	my $pdbout = `convpdb.pl -translate $tvec[0] $tvec[1] $tvec[2] -chain A $pdb | grep -v "END" | sed "s/HSD/HIS/"`;
	my $outf = $pdb;
	$outf =~ s/.pdb/${i}.pdb/;
	open OUT, "> $outf";
	print OUT $pdbout;
	close OUT;
	`cat $pdb | grep " B " >> $outf`;
}

sub makeUnitVector{
	my $l = vectorLength(@_);
#	print "LENGTH: " . $l . "\n";
	return ($_[0] / $l, $_[1] / $l, $_[2] / $l);
}

sub vectorMultiply{
	return ($_[0] * $_[3], $_[1] * $_[3], $_[2] * $_[3]);
}

sub vectorLength{
	my $lx = $_[0];
	my $ly = $_[1];
	my $lz = $_[2];
	return ( sqrt ( $x ** 2 + $y ** 2 + $z ** 2 ));
}
