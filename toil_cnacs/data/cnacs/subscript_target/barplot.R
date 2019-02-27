inputPath <- commandArgs()[5];
outputPath <- commandArgs()[6];

tmp <- scan(inputPath, sep=",")
num <- length(tmp) / 4
input <- matrix(tmp, nrow=num, ncol=4)

xMean <- apply(input, 2, mean)
xSd <- apply(input, 2, sd)
y_max <- 0.1 + max(xMean + xSd)
coord <- barplot(xMean, ylab="Relative rate of sequenced unique reads", xlab="Fragments' length", ylim=c(0, y_max))

pdf(file=outputPath, height=600/72, width=800/72)
barplot(xMean, ylab="Sequenced unique reads (%)", xlab="Fragments' length", ylim=c(0, y_max))
par(new=T)
arrows(coord[2:4], xMean[2:4] - xSd[2:4], coord[2:4], xMean[2:4] + xSd[2:4], angle = 90, length = 0.1)
par(new=T)
arrows(coord[2:4], xMean[2:4] + xSd[2:4], coord[2:4], xMean[2:4] - xSd[2:4], angle = 90, length = 0.1)
dev.off();
