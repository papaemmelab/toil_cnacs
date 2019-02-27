inputPath <- commandArgs()[5];
centromerePath <- commandArgs()[6];
outputPath <- commandArgs()[7];

tmp <- scan(inputPath, sep=",")
number <- length(tmp) / 3
input <- matrix(tmp, 3, number)

idx_all <- ( input[2,] == 1 )
pos_all <- input[1,idx_all]

idx_snp <- ( input[3,] == 1 )
pos_snp <- input[1,idx_snp]


tmp2 <- scan(centromerePath)
number2 <- length(tmp2)
centromere <- matrix(tmp2, 1, number2)


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
plot(dummy_x, dummy_y, xlim=c(0,3036), ylim=c(0,3), xlab="", ylab="", xaxt="n", yaxt="n")
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
segments(pos_all, 1.7, pos_all, 2.3, lwd=0.05)
segments(pos_snp, 0.7, pos_snp, 1.3, lwd=0.05)
segments(0,1,3036,1)
segments(0,2,3036,2)
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
dev.off()
