read_rate <- function (d) {
	diff <- function (x) {
		y = ( x / log(1-x) ) - d + 1
		return(y)
	}
	
	output <- 1
	if ( d < 0.9 ) {
		rate <- uniroot(diff, c(0.000000001, 0.999999999))
		output <- rate$root
	}
	
	return(output)
}

inputPath1 <- commandArgs()[5];
inputPath2 <- commandArgs()[6];
inputPath3 <- commandArgs()[7];
inputPath4 <- commandArgs()[8];
dupPath    <- commandArgs()[9];
coefPath   <- commandArgs()[10];
outputPath <- commandArgs()[11];

tmp1<-read.table(file=inputPath1, sep="\t", header=FALSE)
rate1<-tmp1$V4

tmp2<-read.table(file=inputPath2, sep="\t", header=FALSE)
rate2<-tmp2$V4

tmp3<-read.table(file=inputPath3, sep="\t", header=FALSE)
rate3<-tmp3$V4

tmp4<-read.table(file=inputPath4, sep="\t", header=FALSE)
rate4<-tmp4$V4

tmp5 <- scan(dupPath, sep="\t")
num5 <- length(tmp5)
input5 <- matrix(tmp5, 1, num5)
dup1 <- input5[1,1]
dup2 <- input5[1,2]
dup3 <- input5[1,3]
dup4 <- input5[1,4]

frac1 <- 1
frac2 <- 1
frac3 <- 1
frac4 <- 1
coef <- c(0,0,0,0)

if ( ( dup1 > 0 ) && ( dup2 > 0 ) && ( dup3 > 0 ) && ( dup4 > 0 ) ) {
	frac1 <- read_rate(dup1)
	frac2 <- read_rate(dup2)
	frac3 <- read_rate(dup3)
	frac4 <- read_rate(dup4)
	coef <- c(frac1, frac2, frac3, frac4)
}

vec <- ( rate1 / frac1 ) + ( rate2 / frac2 ) + ( rate3 / frac3 ) + ( rate4 / frac4 )
depth <- vec / mean(vec)
write(depth, file=outputPath, sep=",")

write.table(coef, file=coefPath, col.names=F, row.names=F, quote=F)
