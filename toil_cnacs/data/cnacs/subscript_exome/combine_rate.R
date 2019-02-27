inputPath1 <- commandArgs()[5];
inputPath2 <- commandArgs()[6];
inputPath3 <- commandArgs()[7];
inputPath4 <- commandArgs()[8];
coefPath   <- commandArgs()[9];
outputPath <- commandArgs()[10];

tmp1<-read.table(file=inputPath1, sep="\t", header=FALSE)
rate1<-tmp1$V4

tmp2<-read.table(file=inputPath2, sep="\t", header=FALSE)
rate2<-tmp2$V4

tmp3<-read.table(file=inputPath3, sep="\t", header=FALSE)
rate3<-tmp3$V4

tmp4<-read.table(file=inputPath4, sep="\t", header=FALSE)
rate4<-tmp4$V4

tmp5 <- scan(coefPath, sep="\t")
num5 <- length(tmp5)
input5 <- matrix(tmp5, 1, num5)
frac1 <- input5[1,1]
frac2 <- input5[1,2]
frac3 <- input5[1,3]
frac4 <- input5[1,4]

if ( ( frac1 == 0 ) || ( frac2 == 0 ) || ( frac3 == 0 ) || ( frac4 == 0 ) ) {
	frac1 <- 1
	frac2 <- 1
	frac3 <- 1
	frac4 <- 1
}

vec <- ( rate1 / frac1 ) + ( rate2 / frac2 ) + ( rate3 / frac3 ) + ( rate4 / frac4 )
depth <- vec / mean(vec)
write(depth, file=outputPath, sep=",")
