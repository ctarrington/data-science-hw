library("rjags")
library("car")  # load the 'car' package
data("Anscombe")  # load the data set
?Anscombe  # read a description of the data
head(Anscombe)  # look at the first few lines of the data
pairs(Anscombe)  # scatter plots for each pair of variables


# model it
cleaned = na.omit(Anscombe)
plot(education ~ income, data = cleaned)
lmod = lm(education ~ income + young + urban, data = cleaned)
summary(lmod)
plot(lmod)

abline(lmod)



mod_string = " model {
    for (i in 1:length(education)) {
        education[i] ~ dnorm(mu[i], prec)
        mu[i] = b0 + b[1]*income[i] + b[2]*young[i] + b[3]*urban[i]
    }
    
    b0 ~ dnorm(0.0, 1.0/1.0e6)
    for (i in 1:3) {
        b[i] ~ dnorm(0.0, 1.0/1.0e6)
    }
    
    prec ~ dgamma(1.0/2.0, 1.0*1500.0/2.0)
    	## Initial guess of variance based on overall
    	## variance of education variable. Uses low prior
    	## effective sample size. Technically, this is not
    	## a true 'prior', but it is not very informative.
    sig2 = 1.0 / prec
    sig = sqrt(sig2)
} "

data_jags = as.list(Anscombe)

set.seed(72)
params1 = c("b", "sig")

inits1 = function() {
  inits = list("b"=rnorm(3,0.0,100.0), "prec"=rgamma(1,1.0,1.0))
}

mod1 = jags.model(textConnection(mod_string), data=data_jags, inits=inits1, n.chains=3)
update(mod1, 5000) # burn-in

mod1_sim = coda.samples(model=mod1,
                        variable.names=params1,
                        n.iter=100*1000)

mod1_csim = do.call(rbind, mod1_sim) # combine multiple chains
mean(mod1_csim[,1] > 0.080)

plot(mod1_sim)
gelman.diag(mod1_sim)
gelman.plot(mod1_sim)
autocorr.diag(mod1_sim)
autocorr.plot(mod1_sim)
effectiveSize(mod1_sim)
summary(mod1_sim)

dic.samples(mod1, n.iter=1e5)
# penalized deviance 486

# sample model for income > 0
income_sim = coda.samples(model = mod1, variable.names = c("b[1]"), n.iter = 1e5)
summary(income_sim$mcmc)

# no urban
mod_no_urban_string = " model {
    for (i in 1:length(education)) {
        education[i] ~ dnorm(mu[i], prec)
        mu[i] = b0 + b[1]*income[i] + b[2]*young[i] 
    }
    
    b0 ~ dnorm(0.0, 1.0/1.0e6)
    for (i in 1:2) {
        b[i] ~ dnorm(0.0, 1.0/1.0e6)
    }
    
    prec ~ dgamma(1.0/2.0, 1.0*1500.0/2.0)
    	## Initial guess of variance based on overall
    	## variance of education variable. Uses low prior
    	## effective sample size. Technically, this is not
    	## a true 'prior', but it is not very informative.
    sig2 = 1.0 / prec
    sig = sqrt(sig2)
} "

data_jags = as.list(Anscombe)

set.seed(72)
params_no_urban = c("b", "sig")

inits_no_urban = function() {
  inits = list("b"=rnorm(2,0.0,100.0), "prec"=rgamma(1,1.0,1.0))
}

mod_no_urban = jags.model(textConnection(mod_no_urban_string), data=data_jags, inits=inits_no_urban, n.chains=3)
update(mod_no_urban, 5000) # burn-in

mod_no_urban_sim = coda.samples(model=mod_no_urban,
                        variable.names=params_no_urban,
                        n.iter=1e5)

mod_no_urban_csim = do.call(rbind, mod_no_urban_sim) # combine multiple chains
summary(mod_no_urban_csim)

plot(mod_no_urban_sim)
gelman.diag(mod_no_urban_sim)
gelman.plot(mod_no_urban_sim)
autocorr.diag(mod_no_urban_sim)
autocorr.plot(mod_no_urban_sim)
effectiveSize(mod_no_urban_sim)
summary(mod_no_urban_sim)

dic.samples(mod_no_urban, n.iter=1e5)
# penalized deviance 493.3


# no urban, income * youth
mod_incomebyyouth_no_urban_string = " model {
    for (i in 1:length(education)) {
        education[i] ~ dnorm(mu[i], prec)
        mu[i] = b0 + b[1]*income[i] + b[2]*young[i] + b[3]*income[i]*young[i] 
    }
    
    b0 ~ dnorm(0.0, 1.0/1.0e6)
    for (i in 1:3) {
        b[i] ~ dnorm(0.0, 1.0/1.0e6)
    }
    
    prec ~ dgamma(1.0/2.0, 1.0*1500.0/2.0)
    	## Initial guess of variance based on overall
    	## variance of education variable. Uses low prior
    	## effective sample size. Technically, this is not
    	## a true 'prior', but it is not very informative.
    sig2 = 1.0 / prec
    sig = sqrt(sig2)
} "

data_jags = as.list(Anscombe)

set.seed(72)
params_incomebyyouth_no_urban = c("b", "sig")

inits_incomebyyouth_no_urban = function() {
  inits = list("b"=rnorm(3,0.0,100.0), "prec"=rgamma(1,1.0,1.0))
}

mod_incomebyyouth_no_urban = jags.model(textConnection(mod_incomebyyouth_no_urban_string), data=data_jags, inits=inits_incomebyyouth_no_urban, n.chains=3)
update(mod_incomebyyouth_no_urban, 5000) # burn-in

mod_incomebyyouth_no_urban_sim = coda.samples(model=mod_incomebyyouth_no_urban,
                        variable.names=params_incomebyyouth_no_urban,
                        n.iter=1e5)

mod_incomebyyouth_no_urban_csim = do.call(rbind, mod_incomebyyouth_no_urban_sim) # combine multiple chains
summary(mod_incomebyyouth_no_urban_csim)

plot(mod_incomebyyouth_no_urban_sim)
gelman.diag(mod_incomebyyouth_no_urban_sim)
gelman.plot(mod_incomebyyouth_no_urban_sim)
autocorr.diag(mod_incomebyyouth_no_urban_sim)
autocorr.plot(mod_incomebyyouth_no_urban_sim)
effectiveSize(mod_incomebyyouth_no_urban_sim)
summary(mod_incomebyyouth_no_urban_sim)

dic.samples(mod_incomebyyouth_no_urban, n.iter=1e5)
# penalized deviance 492
