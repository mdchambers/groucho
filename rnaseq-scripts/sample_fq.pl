#!/usr/bin/env perl
use lib "/u/home/m/mchamber/.perl/lib64/perl5";
use strict;
use warnings;
use Getopt::Std;
use PerlIO::gzip;
my $USAGE ='
Usage: sample_fastq.pl  -h num file

Pulls <num> random lines from a fastq <file>

Michael Chambers, 2014
';

our($opt_h);
getopts('h');
&usage if($opt_h);
&usage if($#ARGV < 1);

my ($number, $file) = @ARGV;

if($file =~ /.*\.gz/){
    open FILE, "<:gzip", $file or die "Could not open $file using gzip\n";
} else {
    open FILE, "<", $file or die "Could not open file\n";
}

my $len = 0;
$len++ while(<FILE>);
$len = $len / 4;

close FILE;

if($file =~ /.*\.gz/){
    open FILE, "<:gzip", $file or die "Could not open $file using gzip\n";
} else {
    open FILE, "<", $file or die "Could not open file\n";
}

my $cutoff = 1 - $number / $len;

my $line = 0;
my $flag = 0;
my $printing = 0;
while(<FILE>){
	$flag++ if( rand() >= $cutoff);
	if($line % 4 == 0 && $flag){
		$printing = 4;
		$flag = 0;
		$number--;
	}
	if($printing){
		print;
		--$printing;
	}
	$line++;
	last if $number <= 0 && ! $printing;
}

# my $plines = 0;
# while(<FILE>){
#     if($plines > 0){
#         print;
#         $plines--;
#     } elsif( /^@/ && rand() >= $cutoff){
#         print;
#         $plines = 3;
#     }
# }

close FILE;

print STDERR "DONE " . $file . " " . `date`;

sub usage{
    print STDERR $USAGE;
    exit 2;
}
