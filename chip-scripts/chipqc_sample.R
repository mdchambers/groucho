#!/usr/bin/env Rscript

usage <- '
Usage: chipqc_sample.R bam_file peaks_file env_save_file

Genreates a ChIPQCsample object from the given bam and peaks file and saves it to the designated file

File should be loaded with readRDS'

# Designate where this particular library is
.libPaths("~/lib/R-lib/bioconductor-stable")

args <- commandArgs(T)
if(length(args) != 3){
	stop("Not enough arguments!\n", usage)
}

require(MyChIPQC)


bam <- args[1]
peaks <- args[2]
output <- args[3]

chrom <- c("chr2L", "chr2R", "chr3L", "chr3R", "chr4", "chrX")

if(peaks == "NULL"){
	my.exp <- ChIPQCsample(reads=bam, annotation="dm3", chromosomes=chrom)
} else {
	my.exp <- ChIPQCsample(reads=bam, peaks=peaks, annotation="dm3", chromosomes=chrom)
}

saveRDS(my.exp, file=output)

