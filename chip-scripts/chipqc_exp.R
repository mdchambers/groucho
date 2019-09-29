#!/usr/bin/env Rscript

usage='chipqc_exp.R sample_sheet output_rds'

args <- commandArgs(T)
if(length(args) != 2){
	stop("Not enough args!\n", usage)
}

.libPaths("~/lib/R-lib/bioconductor-stable")
require(MyChIPQC)

ss <- args[1]
output <- args[3]

ss <- read.table(ss, header=T)
my.exp <- ChIPQC(ss, consensus=T, bCount=T, summits=250, annotation="dm3")
saveRDS(my.exp, file=output)
