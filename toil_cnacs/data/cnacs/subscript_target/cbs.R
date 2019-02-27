library(DNAcopy);

sampleName <- commandArgs()[5];
inputPath <- commandArgs()[6];
outputPath <- commandArgs()[7];
alpha_value <- commandArgs()[8];

data <- read.table(inputPath, sep=",");

chr <- rep(0, length(data[,1]));
for (i in 1:22) {
	chr[data[,1] == paste("chr", i, sep="")] <- i;
}
chr[data[,1] == "chrX"] <- 23;
chr[data[,1] == "chrY"] <- 24;

pos <- data[,2];
signal <- data[,3];

CNA.object <- CNA(signal, chr, pos, data.type = "logratio", sampleid = sampleName)
smoothed.CNA.object <- smooth.CNA(CNA.object)
segment.smoothed.CNA.object <- segment(smoothed.CNA.object, alpha=as.numeric(alpha_value), undo.splits="prune", undo.prune=0.01, min.width=2, verbose=3)

write.table(segment.smoothed.CNA.object$output, outputPath, sep="\t", row.names=F, col.names=F);