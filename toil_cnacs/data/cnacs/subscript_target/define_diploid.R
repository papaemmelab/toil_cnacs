inputPath <- commandArgs()[5];
diploidPath <- commandArgs()[6];

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

write.table(dip_region, file=diploidPath, quote=F, row.names=F, col.names=F, sep="\t")
