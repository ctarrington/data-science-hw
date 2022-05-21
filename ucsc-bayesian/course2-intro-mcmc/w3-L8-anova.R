library("rjags")

data("PlantGrowth")
?PlantGrowth
head(PlantGrowth)

boxplot(weight ~ group, data=PlantGrowth)

lmod = lm(weight ~ group, data=PlantGrowth)
summary(lmod)

anova(lmod)

# JAGS
mod_string = " model {
    for (i in 1:length(y)) {
        y[i] ~ dnorm(mu[grp[i]], prec)
    }
    
    for (j in 1:3) {
        mu[j] ~ dnorm(0.0, 1.0/1.0e6)
    }
    
    prec ~ dgamma(5/2.0, 5*1.0/2.0)
    sig = sqrt( 1.0 / prec )
} "

set.seed(82)
str(PlantGrowth)
data_jags = list(y=PlantGrowth$weight, 
                 grp=as.numeric(PlantGrowth$group))

params = c("mu", "sig")

inits = function() {
  inits = list("mu"=rnorm(3,0.0,100.0), "prec"=rgamma(1,1.0,1.0))
}

mod = jags.model(textConnection(mod_string), data=data_jags, inits=inits, n.chains=3)
update(mod, 1e3)

mod_sim = coda.samples(model=mod,
                       variable.names=params,
                       n.iter=5e3)
mod_csim = as.mcmc(do.call(rbind, mod_sim)) # combined chains

plot(mod_sim)
summary(mod_sim)
dic.samples(mod, n.iter=1e5)

gelman.diag(mod_sim)
autocorr.diag(mod_sim)
effectiveSize(mod_sim)


# calculate the residuals
(pm_params = colMeans(mod_csim))
yhat = pm_params[1:3][data_jags$grp]
resid = data_jags$y - yhat
plot(resid)
plot(yhat, resid)

# ask questions based on samples from the posterior
mean(mod_csim[,3] > mod_csim[,1])
mean(mod_csim[,3] > 1.1*mod_csim[,1])

# Quiz

HPDinterval(mod_csim[,3] - mod_csim[,1])


# independent std per factor
mod_string2 = " model {
    for (i in 1:length(y)) {
        y[i] ~ dnorm(mu[grp[i]], prec[grp[i]])
    }
    
    for (j in 1:3) {
        mu[j] ~ dnorm(0.0, 1.0/1.0e6)
    }
    
    for (j in 1:3) {
      prec[j] ~ dgamma(5/2.0, 5*1.0/2.0)
      sig[j] = sqrt( 1.0 / prec[j] )
    }
} "

set.seed(82)
str(PlantGrowth)
data_jags = list(y=PlantGrowth$weight, 
                 grp=as.numeric(PlantGrowth$group))

params2 = c("mu", "sig")

inits2 = function() {
  inits = list("mu"=rnorm(3,0.0,100.0), "prec"=rgamma(3,1.0,1.0))
}

mod2 = jags.model(textConnection(mod_string2), data=data_jags, inits=inits2, n.chains=3)
update(mod2, 1e3)

mod_sim2 = coda.samples(model=mod2,
                       variable.names=params2,
                       n.iter=5e3)
mod_csim2 = as.mcmc(do.call(rbind, mod_sim2)) # combined chains

plot(mod_sim2)
summary(mod_sim2)
dic.samples(mod2, n.iter=1e5)

gelman.diag(mod_sim2)
autocorr.diag(mod_sim2)
effectiveSize(mod_sim2)

# calculate the residuals
(pm_params2 = colMeans(mod_csim2))
yhat2 = pm_params2[1:3][data_jags$grp]
resid2 = data_jags$y - yhat2
plot(resid2)
plot(yhat2, resid2)


dic.samples(mod, n.iter=1e5) -  dic.samples(mod2, n.iter=1e5)

