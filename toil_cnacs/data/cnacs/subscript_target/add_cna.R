inputPath <- commandArgs()[5];
outputPath <- commandArgs()[6];
plotPath <- commandArgs()[7];

library(DPpackage)
data <- read.table(inputPath, header=F, sep="\t")
na.idx <- ( ( is.na(data$V3) ) | ( is.na(data$V4) ) )
all <- data.frame(chr=data$V1[!na.idx], pos=data$V2[!na.idx], depth=data$V3[!na.idx], as=data$V4[!na.idx])
input <- data.frame(depth=data$V3[!na.idx], as=data$V4[!na.idx])

s2 <- matrix(c(2,0,0,4),ncol=2)
psiinv2 <- solve(matrix(c(2,0,0,4),ncol=2))
prior <- list(alpha=1,m2=rep(0,2),s2=s2,psiinv2=psiinv2,nu1=4,nu2=4,tau1=0.1,tau2=0.1)
state <- NULL
nburn <- 200
nsave <- 2000
nskip <- 10
ndisplay <- 200
mcmc <- list(nburn=nburn,nsave=nsave,nskip=nskip,ndisplay=ndisplay)
fit <- DPdensity(input,prior=prior,mcmc=mcmc,state=state,status=TRUE,na.action=na.omit)

nclust <- fit$state$ncluster
dip_idx <- ( fit$state$muclus[1:nclust,2]>-0.152003093 )

if ( sum(dip_idx)>0 ) {
	idx <- (dip_idx[fit$state$ss])
	dip_region <- all[idx,1:2]
} else {
	as_max <- max(fit$state$muclus[1:nclust,2])
	dip_idx <- ( fit$state$muclus[1:nclust,2]==as_max )
	idx <- (dip_idx[fit$state$ss])
	dip_region <- all[idx,1:2]
}

max_depth <- c()
min_depth <- c()
max_as <- c()
min_as <- c()
for ( i in 1:nclust ) {
	max_depth <- c(max_depth,max(input$depth[fit$state$ss==i]))
	min_depth <- c(min_depth,min(input$depth[fit$state$ss==i]))
	max_as <- c(max_as,max(input$as[fit$state$ss==i]))
	min_as <- c(min_as,min(input$as[fit$state$ss==i]))
}

upper_depth <- max(max_depth[dip_idx])
lower_depth <- min(min_depth[dip_idx])
upper_as <- max(max_as[dip_idx])
lower_as <- min(min_as[dip_idx])

flag1 <- 0
while ( flag1 == 0 ) {
flag2 <- 0
	for ( i in 1:nclust ) {
		if ( !dip_idx[i] ) {
			if ( ( max_depth[i] >= lower_depth ) & ( min_depth[i] <= upper_depth ) ) {
				dip_idx[i] <- TRUE
				flag2 <- 1
				upper_depth <- max(max_depth[dip_idx])
				lower_depth <- min(min_depth[dip_idx])
				upper_as <- max(max_as[dip_idx])
				lower_as <- min(min_as[dip_idx])
			}
		}
	}
	
	if ( ( flag2 == 0 ) | ( all(dip_idx) ) ) {
		flag1 <- 1
	}
}

idx2 <- (!dip_idx[fit$state$ss])
cna_region <- all[idx2,1:2]

write.table(cna_region, file=outputPath, quote=F, row.names=F, col.names=F, sep="\t")

pdf(file=plotPath, height=720/72, width=720/72)
plot(input, col=fit$state$ss, pch=16, xlab="Log2(depth ratio)", ylab="Log2(2*BAF)")
dev.off();
