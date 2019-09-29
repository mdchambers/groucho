#!/usr/bin/perl
use strict;
use File::Copy;
use File::Basename;
use Cwd;

my $USAGE = "";
my $file = $ARGV[0];
my @fasc;
my %datasets = ();

&appendFasc($file);

&printFasc;

sub copyFasc{
	my $file = shift;
	my $dir = shift;
	my $newname = basename($dir);
	copy($file, "fascs/${dir}.fasc");
}

sub appendFasc{
	my $f = shift;
	my $full = $f;
	$full =~ s/.fasc//;
	$full =~ s/output_//;
	$full =~ /([A-Za-z0-9\.]+)\.-?[0-9]\.[0-9]{3}.*/;
	my $base = $1;
	open FILE, "< $file";

	my $pdb;
	
	while(my $line = <FILE>){
		chomp $line;
		next if($line =~ /description/);
		my ($ang, $score);
		my @spline = split(/ +/, $line);
		my $ang = $spline[-1];
		$ang =~ /([A-Za-z0-9\.]+)\.?(-?[0-9]\.[0-9]+).*/;
		my $dsetname = $1;
		if( substr ($dsetname, -1, 1) eq '.' ){
			$dsetname = substr($dsetname, 1, -1);
		}
		$ang = $2;
		
		if($ang eq ''){
			$ang = "native";
		}else{
			my $score = $spline[1];
			$datasets{ $dsetname }{ $ang } = $score;
		}
	}
			
}

sub printFasc{
	my $firstline = "Distance\t";
	my $output;
	my @lines;
	my @ang;
	for my $sets (sort(keys %datasets)){
			$firstline .= $sets . "\t";
			@ang = sort(keys(%{$datasets{ $sets }}));
	}
	chomp $firstline;
	$firstline .= "\n";
	$output = $firstline;
	for my $a (sort { $a <=> $b} @ang){
		$output .= $a . "\t";
		for my $sets (sort(keys %datasets)){
			$output .= ${$datasets{ $sets }}{ $a } . "\t";
		}
		chomp $output;
		$output .= "\n";
	}
	print $output;
#	open OUT, "> output.txt";
#	print OUT $output;
#	close OUT;
}
