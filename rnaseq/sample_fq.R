#!/usr/bin/env Rscript
# sample_fastq.R fastq_input num_to_sample fastq_output
# Michael Chambers, 2014
suppressPackageStartupMessages( {
	require(argparse)
})

parser <- ArgumentParser(description="Randomly samples a fastq file. Requires the R packages: ShortRead, argparse")

parser$add_argument("fastq", nargs=1, help="Input fastq or fastq.gz file")
parser$add_argument("number", nargs=1, help="Number of lines to sample")
parser$add_argument("output", nargs=1, help="Name of file for output")

args <- parser$parse_args()

input <- args$fastq
num <- as.integer(args$number)
output <- args$output

suppressPackageStartupMessages(require(ShortRead))

x <- FastqSampler(input, num)

y <- yield(x)

writeFastq(y, output)