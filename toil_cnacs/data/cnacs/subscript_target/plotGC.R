inputPath1 <- commandArgs()[5];
inputPath2 <- commandArgs()[6];
inputPath3 <- commandArgs()[7];
inputPath4 <- commandArgs()[8];
outputPath <- commandArgs()[9];

tmp1 <- scan(inputPath1, sep="\t")
num1 <- length(tmp1) / 4
input1 <- matrix(tmp1, 4, num1)
tmp2 <- scan(inputPath2, sep="\t")
num2 <- length(tmp2) / 4
input2 <- matrix(tmp2, 4, num2)
tmp3 <- scan(inputPath3, sep="\t")
num3 <- length(tmp3) / 4
input3 <- matrix(tmp3, 4, num3)
tmp4 <- scan(inputPath4, sep="\t")
num4 <- length(tmp4) / 4
input4 <- matrix(tmp4, 4, num4)

rate1 <- input1[4,]
rate1 <- rate1 / mean(rate1, na.rm=TRUE)
na_idx1 <- ( is.na(rate1) )
rate1[na_idx1] <- 0

rate2 <- input2[4,]
rate2 <- rate2 / mean(rate2, na.rm=TRUE)
na_idx2 <- ( is.na(rate2) )
rate2[na_idx2] <- 0

rate3 <- input3[4,]
rate3 <- rate3 / mean(rate3, na.rm=TRUE)
na_idx3 <- ( is.na(rate3) )
rate3[na_idx3] <- 0

rate4 <- input4[4,]
rate4 <- rate4 / mean(rate4, na.rm=TRUE)
na_idx4 <- ( is.na(rate4) )
rate4[na_idx4] <- 0

bins=c(1,2,3)

pdf(file=outputPath, height=480/72, width=480/72)
plot(rate1, type = "l", col=rgb(0.827,0,0.278), xlim=c(0,100), ylim=c(0,4), xlab="GC%", ylab="", axes=F)
par(new=T)
plot(rate2, type = "l", col=rgb(0.757,0.561,0), xlim=c(0,100), ylim=c(0,4), xlab="", ylab="", axes=F)
par(new=T)
plot(rate3, type = "l", col=rgb(0.333,0.678,0), xlim=c(0,100), ylim=c(0,4), xlab="", ylab="", axes=F)
par(new=T)
plot(rate4, type = "l", col=rgb(0.118,0.153,0.784), xlim=c(0,100), ylim=c(0,4), xlab="", ylab="", axes=F)
par(new=T)
axis(1, at = c(0,25,50,75,100), labels = c(0,25,50,75,100), las = 0, lwd.ticks=1)
axis(2, at = c(0,1,2,3,4), labels = c(0,1,2,3,4), las = 0, lwd.ticks=1)
mtext("Normalized coverage", side=2, line=3)
segments(50,-100,50,4, col=rgb(0.7,0.7,0.7), lwd=1)
segments(-10,bins,120,bins, col=rgb(0.7,0.7,0.7), lwd=1)
dev.off()
