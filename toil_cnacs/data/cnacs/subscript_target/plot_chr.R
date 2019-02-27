inputPath <- commandArgs()[5];
segmentPath <- commandArgs()[6];
cytobandPath <- commandArgs()[7];
outputPath <- commandArgs()[8];
chr_name <- commandArgs()[9];

chr_num <- as.numeric(chr_name)

tmp <- scan(inputPath, sep=",")
number <- length(tmp) / 4
input_tmp <- matrix(tmp, 4, number)
ind1 <- ( input_tmp[1,] == chr_name )
input <- input_tmp[,ind1]

tmp2 <- scan(segmentPath, sep=",")
number2 <- length(tmp2) / 5
segment_tmp <- matrix(tmp2, 5, number2)
ind2 <- ( segment_tmp[1,] == chr_name )
segment <- segment_tmp[,ind2]

centrome_tmp <- read.table(cytobandPath, sep=",")
ind3 <- ( centrome_tmp[,1] == chr_name )
centrome <- centrome_tmp[ind3,]

pos <- input[2,]
ploidy <- input[3,]
baf <- input[4,]
aaf <- 2 - baf

hetero_ind <- !is.na(input[4,])
hetero_pos <- pos[hetero_ind]
homo_ind <- is.na(input[4,])
homo_pos <- pos[homo_ind]

if ( is.vector(segment) ) {
	x1 <- segment[2]
	x2 <- segment[3]
	y <- segment[4]
	y1 <- segment[5]
} else {
	x1 <- segment[2,]
	x2 <- segment[3,]
	y <- segment[4,]
	y1 <- segment[5,]
}
y <- y
y2 <- 2 - y1

start <- centrome[,2]
end <- centrome[,3]
red_val <- centrome[,4]
blue_val <- centrome[,5]
green_val <- centrome[,6]

chr_length_vector <- c(249250621, 243199373, 198022430, 191154276, 180915260, 171115067, 159138663, 146364022, 141213431, 135534747, 135006516, 133851895, 115169878, 107349540, 102531392, 90354753, 81195210, 78077248, 59128983, 63025520, 48129895, 51304566, 155270560, 59373566)
chr_length <- chr_length_vector[chr_num] %/% 1000000
cur_width <- chr_length * 2.6 / 72

label_pos_vector <- c(-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-28,-28,-34,-30,-50,-50,-28,-40)
label_pos <- label_pos_vector[chr_num]

dummy_x <- c()
dummy_y <- c()

pdf(file=outputPath, onefile=FALSE, width=cur_width, height=320/72)
plot(dummy_x, dummy_y, xlim=c(0,chr_length), ylim=c(0,9), xlab="", ylab="", xaxt="n", yaxt="n")
par(new=T)
plot(pos, ploidy, type = "p", col=rgb(0.4,0.6,1.0), pch=20, cex=0.65, xlim=c(0, chr_length), ylim=c(0, 9), axes=F, xlab="", ylab="")
par(new=T)
plot(pos, baf, type = "p", col=rgb(0,1,0), pch=20, cex=0.65, xlim=c(0, chr_length), ylim=c(0, 9), axes=F, xlab="", ylab="")
par(new=T)
plot(pos, aaf, type = "p", col=rgb(1,0.2,0.4), pch=20, cex=0.65, xlim=c(0, chr_length), ylim=c(0, 9), axes=F, xlab="", ylab="")
par(new=T)
segments(x1, y, x2, y, col=rgb(0,0,0.55), lwd=1.5)
segments(x1, y1, x2, y1, col=rgb(0.14,0.6,0.28), lwd=1.5)
segments(x1, y2, x2, y2, col=rgb(0.5,0.14,0.28), lwd=1.5)
if ( length(homo_pos) > 0 ) {
	segments(homo_pos, 2.8, homo_pos, 3.2, col=rgb(0.85,0.85,0.85), lwd=1)
}
if ( length(hetero_pos) > 0 ) {
	segments(hetero_pos, 2.8, hetero_pos, 3.2, col=rgb(0,0.55,0), lwd=1)
}
axis(2, at = c(0, 1, 2), labels = c(0, 1, 2), las = 0, lwd.ticks=1)
axis(2, at = c(5, 7, 9), labels = c(0, 2, 4), las = 0, lwd.ticks=1)
segments(0,1,chr_length,1)
segments(0,7,chr_length,7)
rect(start, 3.8, end, 4.2, col=rgb(red_val, blue_val, green_val), border=NA)
rect(0, 3.79, chr_length, 4.21, lwd=0.75)
mtext("hetero", side=1, line=-5.6, at=label_pos, cex=0.8)
mtext("SNPs", side=1, line=-4.7, at=label_pos, cex=0.8)
mtext("total CN", side=2, line=2.4, at=7)
mtext("AsCN", side=2, line=2.4, at=1)
dev.off()
