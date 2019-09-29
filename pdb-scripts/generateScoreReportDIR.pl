#!/usr/bin/perl
use strict;
use File::Copy;
use File::Basename;
use Cwd;

my $USAGE = "";

my $startdir = cwd();
my $tdir;
opendir($tdir, ".");

my @fasc;
my %datasets = ();

while(my $file = readdir($tdir)){
	next if ($file eq ".");
	next if ($file eq "..");
	if( $file =~ /fasc/){
		&appendFasc($file);
	}
}

&printFasc;

sub copyFasc{
	my $file = shift;
	my $dir = shift;
	my $newname = basename($dir);
	copy($file, "fascs/${dir}.fasc");
}

sub appendFasc{
	my $file = shift;
	my $dir = $file;
	$dir =~ s/.fasc//;
	$dir =~ s/output_//;
	open FILE, "< $file";

	my $pdb;
	
	while(my $line = <FILE>){
		chomp $line;
		next if($line =~ /description/);
		my ($ang, $score);
		my @spline = split(/ +/, $line);
		my $ang = $spline[-1];
		#print "dir: $dir\n";
		#print "ang: $ang\n";
		if($ang =~ /${dir}\.(.*)(_0001)+/){
			#print "score?\n";
			$ang = $1;
		}else{
			$ang =~ s/${dir}(.*)\_0001_0001/$1/;
		}
		if($ang eq ''){
			$ang = "native";
		}else{
		#print "now: $ang\n";
			my $score = $spline[1];
			$datasets{ $dir }{ $ang } = $score;
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
