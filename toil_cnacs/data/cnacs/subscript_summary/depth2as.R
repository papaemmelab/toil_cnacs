inputPath <- commandArgs()[5];
output1Path <- commandArgs()[6];
output2Path <- commandArgs()[7];

input <- read.table(file=inputPath, sep="\t", header=FALSE)
idx1 <- ( ( is.na(input$V6) ) | ( is.na(input$V7) ) )
depth <- input$V6[!idx1]
as <- input$V7[!idx1]

upd_idx <- ( ( depth > 2 ) & ( depth < 2.2 ) & ( as < 3-depth ) ) | ( ( depth < 2 ) & ( depth > 1.8 ) & ( as < 1.5*depth-2 ) )
cna_idx <- !upd_idx

pdf(file=output1Path, height=640/72, width=640/72)
plot(depth[cna_idx], as[cna_idx], pch=20, xlim=c(1,4), ylim=c(0,1), xlab="Total CNs", ylab="Allelic ratio")
par(new=T)
plot(depth[upd_idx], as[upd_idx], pch=20, col="red", xlim=c(1,4), ylim=c(0,1), xlab="", ylab="", xaxt="n", yaxt="n")
dev.off()

idx2 <- ( depth < 2 )
as[idx2] <- 1 + ( 1 - as[idx2] )

pdf(file=output2Path, height=640/72, width=640/72)
plot(depth[cna_idx], as[cna_idx], pch=20, xlim=c(1,4), ylim=c(0,2), xlab="Total CNs", ylab="Allelic ratio", yaxt="n")
par(new=T)
plot(depth[upd_idx], as[upd_idx], pch=20, xlim=c(1,4), ylim=c(0,2), col="red", xlab="", ylab="", yaxt="n", xaxt="n")
par(new=T)
axis(2, at = c(0, 0.5, 1, 1.5, 2), labels = c(0, 0.5, 1, 0.5, 0), las = 0, lwd.ticks=1)
dev.off()
