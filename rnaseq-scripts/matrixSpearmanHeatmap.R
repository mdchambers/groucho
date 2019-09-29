# matrixSpearmanHeatmap.R
# Michael Chambers, 2013
# Generates a heatmap ("spearman.pdf") of the Spearman rho coefficients between every column in a file
# Lines of input data must be paired observations, with the observation(gene) name in the first row
# and must have a header.
# File is read from input/all.counts if no argument given

args <- commandArgs(T)
counts.file <- ""
if( length(args) == 0 ){
	counts.file <- "input/all.counts"
} else {
	counts.file <- args[1]
}
counts <- read.table(file=counts.file, header=T, row.names=1)
names(counts) <- c("ctrl_0_0", "oe1_0_0", "ctrl_2_0", "oe1_2_0", "ctrl_7_0", "oe1_7_0", "ctrl_0_1", "oe1_0_1", "ctrl_2_1", "oe1_2_1", "ctrl_7_1", "oe1_7_1")
counts <- counts[sort(names(counts))]
n <- ncol(counts)

spearij <- function(i,j,data) {cor.test(data[,i],data[,j],method="spear",exact=F,alternative="t")$estimate}
spear <- Vectorize(spearij,vectorize.args=list("i","j"))
coeffs <- outer(1:n,1:n,spear,data=counts)

library(gplots)
library(RColorBrewer)

pdf("spearman.pdf")
heatmap.2(coeffs,Rowv=T,Colv=T,symm=T,key=T,trace="none",col=brewer.pal(9,"Purples"))
dev.off()