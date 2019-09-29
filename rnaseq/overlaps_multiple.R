
usage <- '
Usage: Rscript all_overlaps.R ref_sqlite bam_file output_prefix

Requirements: myutil, GenomicFeatures, GenomicAlignemnts


'

#####
# Utility functions
#####
overlap.out <- function(my.list, suffix){
	m.counts <- lapply(my.list, function(i){
		c <- summarizeOverlaps(i, bam.file)
		return(as.data.frame(assay(c)))
	})
	m.df <- Reduce(cbind, m.counts)
	colnames(m.df) <- names(m.counts)
	m.df <- rowtofirst(m.df, "Gene")
	write.table(m.df, paste0(out.pref, suffix), quote=F, sep="\t", row.names=F)
}
#####
#####

args <- commandArgs(T)

suppressPackageStartupMessages({
	require(GenomicAlignments)
	require(GenomicFeatures)
	require(myutil)
})

ref.file <- args[1]
bam.file <- args[2]
out.pref <- args[3]

catlog("Loading: ", ref.file, " and generating features.")
ref <- loadDb(ref.file)

catlog("Doing gene-level overlaps...")
genes <- genes(ref)
tx.gn <- transcriptsBy(ref, "gene")
exon.gn <- exonsBy(ref, "gene")
g.list <- named.list(genes, tx.gn, exon.gn)
overlap.out(g.list, "_gene.counts")

catlog("Doing transcript-level overlaps...")
tx <- transcripts(ref)
intron <- intronsByTranscript(ref, use.names=T)
tx.list <- named.list(tx, intron)
overlap.out(tx.list, "_tx.counts")







 