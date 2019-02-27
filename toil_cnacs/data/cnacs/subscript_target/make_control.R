inputOrgPath <- commandArgs()[5];
inputPath <- commandArgs()[6];
normalPath <- commandArgs()[7];
sample.id <- commandArgs()[8];
outputPath <- commandArgs()[9];
diploidPath <- commandArgs()[10];
controlPath <- commandArgs()[11];
controlCoefPath <- commandArgs()[12];

input.org <- read.table(inputOrgPath, sep="\t");
signal.org <- input.org$V3;

input <- read.table(inputPath, sep="\t");
signal <- input$V3;
label <- paste(input$V1, input$V2, sep=";")
idx0 <- grep("chr[0-9]", input$V1)
signal.auto <- signal[idx0]
label.auto <- paste(input$V1[idx0], input$V2[idx0], sep=";")

normal.tmp <- read.table(normalPath, sep="\t");
normal.org <- as.matrix(normal.tmp);
case.idx <- ( colnames(normal.org)==sample.id )
normal <- normal.org[,!case.idx]
idx1 <- grep("chr[0-9]", rownames(normal))
normal.auto <- normal[idx1,]
idx2 <- grep("chr[XY]", rownames(normal))
normal.sex <- normal[idx2,]

result <- lsfit(normal.auto, signal.auto, intercept = FALSE)
control.auto <- signal.auto - result$residuals

sample.num <- ncol(normal)
control.sex <- 0
for ( i in 1:sample.num ) {
	if ( is.matrix( normal.sex ) ) {
		control.sex <-  control.sex + result$coefficients[i] * normal.sex[,i]
	} else {
		control.sex <-  control.sex + result$coefficients[i] * normal.sex[i]
	}
}
control <- c(control.auto, control.sex)

output <- log2(signal.org / control)
signal.data <- data.frame(Label=label, Signal=output)
write.table(signal.data, file=outputPath, quote=F, row.names=F, sep="\t")

diploid <- log2(signal.auto / control.auto)
diploid.data <- data.frame(Label=label.auto, Signal=diploid)
write.table(diploid.data, file=diploidPath, quote=F, row.names=F, sep="\t")

control.data <- data.frame(Label=label, Signal=control)
write.table(control.data, file=controlPath, quote=F, row.names=F, sep="\t")

coef.data <- data.frame(ID=names(result$coefficients), Coef=result$coefficients)
write.table(coef.data, file=controlCoefPath, quote=F, row.names=F, sep="\t")
