inputPath <- commandArgs()[5];
outputPath <- commandArgs()[6];

tmp <- scan(inputPath, sep="\t")
num <- length(tmp) / 4
input <- matrix(tmp, 4, num)

rate <- input[4,]
rate <- rate / mean(rate, na.rm=TRUE)
na_idx <- ( is.na(rate) )
rate[na_idx] <- 0

bins=c(1,2)

pdf(file=outputPath, height=480/72, width=480/72)
plot(rate, type = "l", xlim=c(0,100), ylim=c(0,3), xlab="GC%", ylab="", axes=F)
par(new=T)
axis(1, at = c(0,25,50,75,100), labels = c(0,25,50,75,100), las = 0, lwd.ticks=1)
axis(2, at = c(0,1,2,3), labels = c(0,1,2,3), las = 0, lwd.ticks=1)
mtext("Normalized coverage", side=2, line=3)
segments(50,-100,50,3, col=rgb(0.7,0.7,0.7), lwd=1)
segments(-10,bins,120,bins, col=rgb(0.7,0.7,0.7), lwd=1)
dev.off()
