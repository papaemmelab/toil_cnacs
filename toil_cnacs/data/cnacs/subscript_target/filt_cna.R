inputPath <- commandArgs()[5];
outputPath <- commandArgs()[6];

library(DPpackage)
data <- read.table(inputPath, header=F, sep="\t")
na.idx <- ( ( is.na(data$V6) ) | ( is.na(data$V7) ) )
with_na <- data[na.idx,]
wo_na <- data[!na.idx,]
input <- data.frame(depth=data$V6[!na.idx], as=data$V7[!na.idx])

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
dist <- c()
for ( i in 1:nclust ) {
	dist[i] <- as.numeric( fit$state$muclus[i,] %*% fit$state$muclus[i,] )
}
min_clust <- ( dist != min(dist) )
idx <- ( min_clust[fit$state$ss] )
filtered <- wo_na[idx,]
filtered <- rbind(filtered, with_na)
filtered2 <- filtered[sort.list(filtered$V2),]
name <- paste("",filtered2$V1,"",sep="")
filtered3 <- cbind(name,filtered2[,-1])

write.table(filtered3, file=outputPath, row.names=F, col.names=F, sep="\t")
