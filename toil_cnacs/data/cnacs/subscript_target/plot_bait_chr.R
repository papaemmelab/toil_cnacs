inputPath <- commandArgs()[5];
cytobandPath <- commandArgs()[6];
outputPath <- commandArgs()[7];
chr_name <- commandArgs()[8];

chr_num <- as.numeric(chr_name)

tmp <- scan(inputPath, sep=",")
number <- length(tmp) / 4
input_tmp <- matrix(tmp, 4, number)
idx1 <- ( input_tmp[1,] == chr_name )
input <- input_tmp[,idx1]

idx_all <- ( input[3,] == 1 )
pos_all <- input[2,idx_all]

idx_snp <- ( input[4,] == 1 )
pos_snp <- input[2,idx_snp]


centrome_tmp <- read.table(cytobandPath, sep=",")
idx2 <- ( centrome_tmp[,1] == chr_name )
centrome <- centrome_tmp[idx2,]
start <- centrome[,2]
end <- centrome[,3]
red_val <- centrome[,4]
blue_val <- centrome[,5]
green_val <- centrome[,6]

chr_length_vector <- c(249250621, 243199373, 198022430, 191154276, 180915260, 171115067, 159138663, 146364022, 141213431, 135534747, 135006516, 133851895, 115169878, 107349540, 102531392, 90354753, 81195210, 78077248, 59128983, 63025520, 48129895, 51304566, 155270560, 59373566)
chr_length <- chr_length_vector[chr_num] %/% 1000000
cur_width <- chr_length * 2.6 / 72

dummy_x <- c()
dummy_y <- c()

pdf(file=outputPath, onefile=FALSE, width=cur_width, height=320/72)
plot(dummy_x, dummy_y, xlim=c(0,chr_length), ylim=c(0,3), xlab="", ylab="", xaxt="n", yaxt="n")
par(new=T)
segments(pos_all,2.0,pos_all,2.5,lwd=0.5)
segments(pos_snp,1.0,pos_snp,1.5,lwd=0.5)
rect(start, 0.1, end, 0.5, col=rgb(red_val, blue_val, green_val), border=NA)
rect(0, 0.09, chr_length, 0.51, lwd=0.75)
dev.off()
