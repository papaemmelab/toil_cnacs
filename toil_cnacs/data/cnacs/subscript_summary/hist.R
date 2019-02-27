inputPath <- commandArgs()[5];
outputPath <- commandArgs()[6];
xlabel <- commandArgs()[7];

tmp <- scan(inputPath)
vector.tmp <- as.vector(tmp)
vector <- vector.tmp[!is.na(vector.tmp)]
min <- 0
max <- ( max(vector) %/% 1 ) + 1

bins <- seq(min,max,length=101)
pdf(file=outputPath, height=600/72, width=800/72)
hist(vector, xlim=c(min,max), breaks=bins, freq=TRUE, col="#d6d6d6", border="#000000", xlab=xlabel, ylab="Number of events")
dev.off();