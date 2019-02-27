inputPath <- commandArgs()[5];
centromerePath <- commandArgs()[6];
outputPath <- commandArgs()[7];

tmp <- scan(inputPath, sep="\t")
number <- length(tmp) / 3
input <- matrix(tmp, 3, number)

tmp2 <- scan(centromerePath)
number2 <- length(tmp2)
centromere <- matrix(tmp2, 1, number2)

pos <- input[1,]
gain.tmp <- input[2,]
loss.tmp <- input[3,]

all <- c(gain.tmp, loss.tmp)
y_limit <- floor( max(all)*0.2 ) * 5 + 5
half <- y_limit * 0.5

gain <- 5 + ( 5 * gain.tmp / y_limit )
loss <- 5 - ( 5 * loss.tmp / y_limit )

chr_pos <- c(0, 249, 492, 690, 882, 1063, 1234, 1393, 1539, 1680, 1816, 1951, 2085, 2200, 2307, 2410, 2500, 2581, 2659, 2719, 2782, 2830, 2881, 3036)
label_pos <- numeric(23)
for ( i in 1:23 ) {
	label_pos[i] <- ( chr_pos[i] + chr_pos[i+1] ) * 0.5
}
chr_label <- 1:22
chr_label <- c(chr_label, 'X')

dummy_x <- c()
dummy_y <- c()

pdf(file=outputPath, onefile=FALSE, width=960/72, height=640/72)
plot(dummy_x, dummy_y, xlim=c(0,3036), ylim=c(0,10), xlab="", ylab="", xaxt="n", yaxt="n")
pa <- par("usr")
rect(pa[1],pa[3],pa[2],pa[4], col=rgb(1,1,1), border=NA)
par(new=T)
rect(249,pa[3],492,pa[4], col=rgb(0.97,0.97,0.97), border=NA)
par(new=T)
rect(690,pa[3],882,pa[4], col=rgb(0.97,0.97,0.97), border=NA)
par(new=T)
rect(1063,pa[3],1234,pa[4], col=rgb(0.97,0.97,0.97), border=NA)
par(new=T)
rect(1393,pa[3],1539,pa[4], col=rgb(0.97,0.97,0.97), border=NA)
par(new=T)
rect(1680,pa[3],1816,pa[4], col=rgb(0.97,0.97,0.97), border=NA)
par(new=T)
rect(1951,pa[3],2085,pa[4], col=rgb(0.97,0.97,0.97), border=NA)
par(new=T)
rect(2200,pa[3],2307,pa[4], col=rgb(0.97,0.97,0.97), border=NA)
par(new=T)
rect(2410,pa[3],2500,pa[4], col=rgb(0.97,0.97,0.97), border=NA)
par(new=T)
rect(2581,pa[3],2659,pa[4], col=rgb(0.97,0.97,0.97), border=NA)
par(new=T)
rect(2719,pa[3],2782,pa[4], col=rgb(0.97,0.97,0.97), border=NA)
par(new=T)
rect(2830,pa[3],2881,pa[4], col=rgb(0.97,0.97,0.97), border=NA)
par(new=T)
plot(pos, gain, type = "s", col=rgb(1,0.2,0.4), lwd=3, xlim=c(0, 3036), ylim=c(0, 10), axes=F, xlab="Chromosome", ylab="")
par(new=T)
plot(pos, loss, type = "s", col=rgb(0.2,0.2,1), lwd=3, xlim=c(0, 3036), ylim=c(0, 10), axes=F, xlab="", ylab="")
par(new=T)
axis(2, at = c(0, 2.5, 5, 7.5, 10), labels = c(y_limit, half, 0, half, y_limit), las = 0, lwd.ticks=1)
segments(0,0,3036,0, lty=2)
segments(0,2.5,3036,2.5, lty=2)
segments(0,5,3036,5)
segments(0,7.5,3036,7.5, lty=2)
segments(0,10,3036,10, lty=0.2)
abline(v=0, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=249, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=492, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=690, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=882, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=1063, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=1234, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=1393, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=1539, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=1680, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=1816, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=1951, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=2085, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=2200, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=2307, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=2410, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=2500, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=2581, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=2659, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=2719, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=2782, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=2830, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=2881, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=3036, lty=2, col=rgb(0.3,0.3,0.3))
abline(v=centromere, lty=3, col=rgb(0.7,0.7,0.7))
axis(1, at = chr_pos, labels=F, las = 0, lwd.ticks=1)
mtext(chr_label, side=1, line=1, at=label_pos, cex=0.8)
mtext("Frequency (%, gain)", side=2, line=2.5, at=7.5)
mtext("Frequency (%, loss)", side=2, line=2.5, at=2.5)
dev.off()
