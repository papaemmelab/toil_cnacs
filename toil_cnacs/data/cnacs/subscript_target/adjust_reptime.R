inputPath <- commandArgs()[5];
diploidPath <- commandArgs()[6];
outputPath <- commandArgs()[7];
plotPath <- commandArgs()[8];

input <- read.table(inputPath, sep="\t", header=F)
pos <- input$V1
signal.tmp <- input$V2
time.tmp <- input$V3
na.idx <- ( is.na(time.tmp) )

diploid <- read.table(diploidPath, sep="\t", header=F)
dip_pos <- diploid$V1
dip_signal.tmp <- diploid$V2
dip_time.tmp <- diploid$V3

dip_na.idx <- ( ( is.na(dip_time.tmp) ) | ( is.na(dip_signal.tmp) ) | ( dip_signal.tmp == 0 ) )
dip_signal <- dip_signal.tmp[!dip_na.idx]
dip_time <- dip_time.tmp[!dip_na.idx]
min.sig <- min(dip_signal)

x <- data.frame(dip_time=dip_time, dip_signal=dip_signal)

res<-lm(dip_signal ~ dip_time + 0, data = x)
coef.val<-coef(res)

adjusted <- signal.tmp
adjusted[!na.idx] <- signal.tmp[!na.idx] - time.tmp[!na.idx]*coef.val
output <- data.frame(Label=pos, Signal=adjusted)
write.table(output, file=outputPath, append=F, quote=F, col.names=T, row.names=F, sep="\t")

pdf(file=plotPath, height=900/72, width=900/72)
plot(dip_time, dip_signal, xlab="Replication timing (SD)", ylab="Log2(depth)", pch=20)
par(new=T)
abline(h=0)
abline(v=0)
abline(res)
text(-1,min.sig,coef.val)
dev.off()
