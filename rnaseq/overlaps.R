# Usage:

# Rscript overlaps.R input.bam output.txt


# TODO
# Currently a single read can map to multiple regions.
# I'm not sure how serious a problem this is with real data
# but it should be kept in mind when using the output
# for anything quantitative.

suppressPackageStartupMessages({
	library(GenomicFeatures)
	library(GenomicAlignments)
	# library(myutil)
})

named.list <- function(...){
	setNames(list(...), as.character( match.call()[-1] ) )
}

cmdarg <- commandArgs(TRUE)

# dm3_ref <- makeTranscriptDbFromUCSC(genome="dm3",tablename="refGene")
dm3_ref <- loadDb("~/annotation/FlyBase/dm3_ref.sqlite")

tx <- transcripts(dm3_ref)
exons <- exons(dm3_ref)
introns <- unlist(intronsByTranscript(dm3_ref))
fiveUTR <- unlist(fiveUTRsByTranscript(dm3_ref))
threeUTR <- unlist(threeUTRsByTranscript(dm3_ref))

features <- named.list(tx, exons, introns, fiveUTR, threeUTR)
features <- lapply(features, reduce)

cat("Writing reads from ", cmdarg[1], " to file ", cmdarg[2],"\n", sep="", file=stdout())

reads <- readGAlignmentsFromBam(cmdarg[1])
# param <- ScanBamParam(which=GRanges(seqnames="chr2L", ranges=IRanges(1, 100000)))
# reads <- readGAlignmentsFromBam("/Volumes/Mikedisk/Work.bio/projects/mike_nascent_rnaseq/SxaQSEQsXA065L8_bams/lane01_genome_tophat.bam", param=param)
write.sums <- function(feat, reads, out.prefix, out.suffix, ...){
	co <- sapply(feat, function(f){
		c <- countOverlaps(reads, f, ...)
		c[c > 1] <- 1
		sum(c)
	})
	out.file <- paste0(out.prefix, "_", out.suffix, "_overlaps.txt")
	cat("Input\tTotal", paste(names(co), collapse="\t"), "\n", file=out.file)
	cat(paste(out.prefix, length(reads), paste(co, collapse="\t"), sep="\t"), "\n", file=out.file, append=T)
}

write.sums(features, reads, basename(cmdarg[2]), "standard")
write.sums(features, reads, basename(cmdarg[2]), "nostrand", ignore.strand=T)
write.sums(features, reads, basename(cmdarg[2]), "halfwidth", ignore.strand=T, minoverlap=mean(qwidth(reads[1:10000])) / 2)
write.sums(features, reads, basename(cmdarg[2]), "start", ignore.strand=T, type="start")
write.sums(features, reads, basename(cmdarg[2]), "end", ignore.strand=T, type="end")
write.sums(features, reads, basename(cmdarg[2]), "within", ignore.strand=T, type="within")


