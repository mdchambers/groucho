#!/usr/bin/perl
use strict;
use Getopt::Std;

my $USAGE = 'translatePDBOverRange.pl [ -i increment -p posStop -n negStop] chain1s chain2s pdbfile';

our($opt_i, $opt_n, $opt_p);

getopt('inp');
$opt_i = 1 if( ! defined $opt_i);
$opt_p = 100 if (! defined $opt_p);
$opt_n = 100 if (! defined $opt_n);

unless($#ARGV == 2){
	print $USAGE;
	exit;
}

my ($x, $y, $z, $pdb);
my $chain1 = shift @ARGV;
my $chain2 = shift @ARGV;
$pdb = shift @ARGV;

my @vec = &calcCMVector($chain1, $chain2, $pdb);

my @uvec = &makeUnitVector(@vec);

my $numstructs = ($opt_p - $opt_n) / $opt_i + 1;
my $current = 0;
for(my $i = $opt_n; $i <= $opt_p; $i += $opt_i){
	$current++;
	my $outf = $pdb;
	my $append = sprintf "%.3f", $i;
	if($outf =~ /.pdb/){
		$outf =~ s/pdb/${append}.pdb/;
	}else{
		$outf = $outf . "." . $append;
	}
	if( -e $outf){
		print "Skipping translating $current\n";
		next;
	}
	my @tvec = &vectorMultiply(@uvec, $i);
	print "Translating struct $current / $numstructs\n";
#	print "i: " . $i . "\n";
#	print "OVECTOR: " . "@vec" . "\n";
#	print "UVECTOR: " . "@uvec" . "\n";
#	print "TVECTOR: " . "@tvec" . "\n";
	my $pdbout = `convpdb.pl -translate $tvec[0] $tvec[1] $tvec[2] -chain A $pdb | grep -v "END" | sed "s/HSD/HIS/"`;
		
		
	open OUT, "> $outf";
	print OUT $pdbout;
	open INPDB, "< $pdb";
	while(<INPDB>){
		if(/ B /){
			print OUT;
		}
	}
	close OUT;
}

sub makeUnitVector{
	my $l = vectorLength(@_);
	print "LENGTH: " . $l . "\n";
	return ($_[0] / $l, $_[1] / $l, $_[2] / $l);
}

sub vectorMultiply{
	return ($_[0] * $_[3], $_[1] * $_[3], $_[2] * $_[3]);
}

sub vectorSubtract{
	return ($_[3] - $_[0], $_[4] - $_[1], $_[5] - $_[2]);
}

sub vectorLength{
	my $lx = $_[0];
	my $ly = $_[1];
	my $lz = $_[2];
	return ( sqrt ( $lx ** 2 + $ly ** 2 + $lz ** 2 ));
}

sub calcCMVector{
	my $c1 = shift @_;
	my $c2 = shift @_;
	my $p = shift @_;
	my (@c1, @c2);
	@c1 = split(//, $c1);
	@c2 = split(//, $c2);
	my ($pc1, $pc2);
	open INPDB, "< $pdb";
	while(<INPDB>){
		for my $i (@c1){
			if(/ $i /){
				$pc1 .= $_;
			}
		}
		for my $i (@c2){
			if(/ $i /){
				$pc2 .= $_;
			}
		}
	}
	close INPDB;
	open PC1, "> pc1.temp";
	print PC1 $pc1;
	open PC2, "> pc2.temp";
	print PC2 $pc2;
	my @v1 = split(/ /, `centerOfMass.pl pc1.temp` );
	my @v2 = split(/ /, `centerofMass.pl pc2.temp` );
	my @vdiff = &vectorSubtract( @v1, @v2);
	print "v1 @{v1}\n";
	print "v2 @{v2}\n";
	print "vdiff @{vdiff}\n";
	return @vdiff;
}
			
	
