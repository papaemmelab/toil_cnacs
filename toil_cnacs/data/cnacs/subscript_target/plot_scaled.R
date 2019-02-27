inputPath <- commandArgs()[5];
segmentPath <- commandArgs()[6];
centromerePath <- commandArgs()[7];
outputPath <- commandArgs()[8];

tmp <- scan(inputPath, sep=",")
number <- length(tmp) / 3
input <- matrix(tmp, 3, number)

tmp2 <- scan(segmentPath, sep=",")
number2 <- length(tmp2) / 4
segment <- matrix(tmp2, 4, number2)

tmp3 <- scan(centromerePath)
number3 <- length(tmp3)
centromere <- matrix(tmp3, 1, number3)

pos <- input[1,]
ploidy <- input[2,]
baf <- input[3,]
aaf <- 2 - baf

y_limit <- max(ploidy, na.rm=TRUE)
y_half <- floor(y_limit * 0.5)
max_ploidy <- max(ploidy-4, na.rm=TRUE)
max_ploidy <- floor( max_ploidy ) + 1
max_label <- floor( max_ploidy * 0.5 ) + 1
ploidy_label <- 0:max_label
ploidy_label <- ploidy_label * 2
ploidy_label_pos <- ploidy_label + 4

hetero_ind <- !is.na(input[3,])
hetero_pos <- pos[hetero_ind]
homo_ind <- is.na(input[3,])
homo_pos <- pos[homo_ind]

x1 <- segment[1,]
x2 <- segment[2,]
y <- segment[3,]
y1 <- segment[4,]
y2 <- 2 - y1

chr_pos <- c(0, 249, 492, 690, 882, 1063, 1234, 1393, 1539, 1680, 1816, 1951, 2085, 2200, 2307, 2410, 2500, 2581, 2659, 2719, 2782, 2830, 2881, 3036)
label_pos <- numeric(23)
for ( i in 1:23 ) {
	label_pos[i] <- ( chr_pos[i] + chr_pos[i+1] ) * 0.5
}
chr_label <- 1:22
chr_label <- c(chr_label, 'X')

dummy_x <- c()
dummy_y <- c()

pdf(file=outputPath, onefile=FALSE, width=960/72, height=320/72)
plot(dummy_x, dummy_y, xlim=c(0,3036), ylim=c(0, y_limit), xlab="", ylab="", xaxt="n", yaxt="n")
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
plot(pos, ploidy, type = "p", col=rgb(0.4,0.6,1.0), pch=20, cex=0.65, xlim=c(0, 3036), ylim=c(0, y_limit), axes=F, xlab="Chromosome", ylab="")
par(new=T)
plot(pos, baf, type = "p", col=rgb(0,1,0), pch=20, cex=0.65, xlim=c(0, 3036), ylim=c(0, y_limit), axes=F, xlab="", ylab="")
par(new=T)
plot(pos, aaf, type = "p", col=rgb(1,0.2,0.4), pch=20, cex=0.65, xlim=c(0, 3036), ylim=c(0, y_limit), axes=F, xlab="", ylab="")
par(new=T)
segments(x1, y, x2, y, col=rgb(0,0,0.55), lwd=2.5)
segments(x1, y1, x2, y1, col=rgb(0.14,0.6,0.28), lwd=2.5)
segments(x1, y2, x2, y2, col=rgb(0.5,0.14,0.28), lwd=2.5)
if ( length(homo_pos) > 0 ) {
	segments(homo_pos, 2.8, homo_pos, 3.2, col=rgb(0.85,0.85,0.85), lwd=1)
}
if ( length(hetero_pos) > 0 ) {
	segments(hetero_pos, 2.8, hetero_pos, 3.2, col=rgb(0,0.55,0), lwd=1)
}
axis(2, at = c(0, 1, 2), labels = c(0, 1, 2), las = 0, lwd.ticks=1)
axis(2, at = ploidy_label_pos, labels = ploidy_label, las = 0, lwd.ticks=1)
segments(0,1,3036,1)
segments(0,6,3036,6)
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
mtext("total CN", side=2, line=2.5, at=y_half)
mtext("AsCN", side=2, line=2.5, at=1)
dev.off()
