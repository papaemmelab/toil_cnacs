gainPath <- commandArgs()[5];
lossPath <- commandArgs()[6];
cytobandPath <- commandArgs()[7];
outputPath <- commandArgs()[8];
chr_name <- commandArgs()[9];

chr_num <- as.numeric(chr_name)

gain.tmp <- scan(gainPath, sep="\t")
gain.number <- length(gain.tmp)
input_gain_tmp <- matrix(gain.tmp, 5, gain.number)
ind_gain <- ( input_gain_tmp[1,] == chr_num )
input_gain <- input_gain_tmp[,ind_gain]

loss.tmp <- scan(lossPath, sep="\t")
loss.number <- length(loss.tmp)
input_loss_tmp <- matrix(loss.tmp, 5, loss.number)
ind_loss <- ( input_loss_tmp[1,] == chr_num )
input_loss <- input_loss_tmp[,ind_loss]

centrome_tmp <- read.table(cytobandPath, sep=",")
ind_centromere <- ( centrome_tmp[,1] == chr_num )
centrome <- centrome_tmp[ind_centromere,]

if ( length(input_gain) == 0 ) {
	gain_num <- 0
	upper_gain <- 0
	lower_gain <- 0
	start_gain <- 0
	end_gain <- 0
	red_val_gain <- 1
	gb_val_gain <- 1
} else if ( is.matrix(input_gain) )  {
	gain_num <- max(input_gain[2,])
	upper_gain <- 0.3 + ( input_gain[2,] + 0.95 ) * 0.1
	lower_gain <- 0.3 + ( input_gain[2,] + 0.05 ) * 0.1
	start_gain <- input_gain[3,] / 1000000
	end_gain <- input_gain[4,] / 1000000
	total_gain <- input_gain[5,]
	
	high_idx <- ( input_gain[5,] > 5 )
	int_idx <- ( input_gain[5,] > 3) & ( input_gain[5,] <= 5 )
	low_idx <- ( input_gain[5,] <= 3 )
	
	red_val_gain <- 1
	red_val_gain[high_idx] <- 0.5
	red_val_gain[int_idx] <- 1 - 0.25 * ( total_gain[int_idx] - 3 )
	red_val_gain[low_idx] <- 1
	
	gb_val_gain <- 0
	gb_val_gain[high_idx] <- 0
	gb_val_gain[int_idx] <- 0
	gb_val_gain[low_idx] <- 0.8 - 0.8 * ( total_gain[low_idx] - 2 )
} else if ( is.vector(input_gain) ) {
	gain_num <- max(input_gain[2])
	upper_gain <- 0.3 + ( input_gain[2] + 0.95 ) * 0.1
	lower_gain <- 0.3 + ( input_gain[2] + 0.05 ) * 0.1
	start_gain <- input_gain[3] / 1000000
	end_gain <- input_gain[4] / 1000000
	total_gain <- input_gain[5]
	red_val_gain <- 1 - 0.25 * ( total_gain - 3 )
	red_val_gain <- min(1, red_val_gain)
	red_val_gain <- max(0.5, red_val_gain)
	gb_val_gain <- 0.8 - 0.8 * ( total_gain -2 )
	gb_val_gain <- max(0, gb_val_gain)
}


if ( length(input_loss) == 0 ) {
	loss_num <- 0
	upper_loss <- 0
	lower_loss <- 0
	start_loss <- 0
	end_loss <- 0
	blue_val_loss <- 1
	rg_val_loss <- 1
} else if ( is.matrix(input_loss) ) {
	loss_num <- max(input_loss[2,])
	upper_loss <- -0.3 - ( loss_num - input_loss[2,] + 1.05 ) * 0.1
	lower_loss <- -0.3 - ( loss_num - input_loss[2,] + 1.95 ) * 0.1
	start_loss <- input_loss[3,] / 1000000
	end_loss <- input_loss[4,] / 1000000
	total_loss <- input_loss[5,]
	
	high_idx <- ( input_loss[5,] < 1 )
	low_idx <- ( input_loss[5,] >= 1 )
	
	blue_val_loss <- 1
	blue_val_loss[high_idx] <- 1 - 0.5 * ( 1 - total_loss[high_idx] )
	blue_val_loss[low_idx] <- 1
	
	rg_val_loss <- 0
	rg_val_loss[high_idx] <- 0
	rg_val_loss[low_idx] <- 0.8 - 0.8 * ( 2 - total_loss[low_idx] )
} else if ( is.vector(input_loss) ) {
	loss_num <- max(input_loss[2])
	upper_loss <- -1 * ( loss_num - input_loss[2] + 1.05 ) * 0.1
	lower_loss <- -1 * ( loss_num - input_loss[2] + 1.95 ) * 0.1
	start_loss <- input_loss[3] / 1000000
	end_loss <- input_loss[4] / 1000000
	total_loss <- input_loss[5]
	blue_val_loss <- 1 - 0.5 * ( 1 - total_loss )
	blue_val_loss <- min(1, blue_val_loss)
	blue_val_loss <- max(0.5, blue_val_loss)
	rg_val_loss <- 0.8 - 0.8 * ( 2 - total_loss )
	rg_val_loss <- max(0, blue_val_loss)
}


start <- centrome[,2]
end <- centrome[,3]
red_val <- centrome[,4]
blue_val <- centrome[,5]
green_val <- centrome[,6]


chr_length_vector <- c(249250621, 243199373, 198022430, 191154276, 180915260, 171115067, 159138663, 146364022, 141213431, 135534747, 135006516, 133851895, 115169878, 107349540, 102531392, 90354753, 81195210, 78077248, 59128983, 63025520, 48129895, 51304566, 155270560, 59373566)
chr_length <- chr_length_vector[chr_num] %/% 1000000
cur_width <- chr_length * 11 / 72

y_max <- 0.5 + ( gain_num * 0.1 )
y_min <- -0.5 - ( loss_num * 0.1 )
cur_height <- ( y_max - y_min ) * 300 / 72

label_pos_vector <- c(-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-24,-28,-28,-34,-30,-50,-50,-28,-40)
label_pos <- label_pos_vector[chr_num]

dummy_x <- c()
dummy_y <- c()

pdf(file=outputPath, onefile=FALSE, width=cur_width, height=cur_height)
plot(dummy_x, dummy_y, xlim=c(0, chr_length), ylim=c(y_min, y_max), xlab="", ylab="", xaxt="n", yaxt="n")
par(new=T)
rect(start_gain, lower_gain, end_gain, upper_gain, col=rgb(red_val_gain, gb_val_gain, gb_val_gain), border=NA)
rect(start_loss, lower_loss, end_loss, upper_loss, col=rgb(rg_val_loss, rg_val_loss, blue_val_loss), border=NA)
rect(start, -0.2, end, 0.2, col=rgb(red_val, blue_val, green_val), border=NA)
rect(0, -0.21, chr_length, 0.21, lwd=0.75)
dev.off()
