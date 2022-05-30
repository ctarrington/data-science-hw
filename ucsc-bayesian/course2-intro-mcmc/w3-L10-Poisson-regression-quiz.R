library("rjags")

dat = read.csv(file="callers.csv", header = TRUE)
head(dat)

any(is.na(dat))

#eda
hist(dat$calls)
hist(dat$calls/dat$days_active)

boxplot(calls ~ isgroup2, data = dat)
boxplot(calls/days_active ~ isgroup2, data = dat)

plot(calls/days_active ~ age, data = dat, subset = isgroup2==0)
points(calls/days_active ~ age, data = dat, subset = isgroup2==1, col="red")

# build a model for jags
mod_string = " model {
    for (i in 1:length(calls)) {
		    calls[i] ~ dpois( days_active[i] * lam[i] )
		    log(lam[i]) = b0 + b[1]*age[i] + b[2]*isgroup2[i]
    }
    
    for (j in 1:2) {
        b[j] ~ dnorm(0.0, 1.0/1.0e4)
    }
    b0 ~ dnorm(0.0, 1.0/1e4)
} "

set.seed(102)

data_jags = as.list(dat)

params = c("b0", "b")

mod = jags.model(textConnection(mod_string), data=data_jags, n.chains=3)
update(mod, 1e3)

mod_sim = coda.samples(model=mod,
                       variable.names=params,
                       n.iter=5e3)
mod_csim = as.mcmc(do.call(rbind, mod_sim))

## convergence diagnostics
plot(mod_sim)

gelman.diag(mod_sim)
autocorr.diag(mod_sim)
autocorr.plot(mod_sim)
effectiveSize(mod_sim)

## compute DIC
dic = dic.samples(mod, n.iter=1e3)

summary(mod_sim)
## posterior probability that b[2] > 0
head(mod_csim[,2])
mean(mod_csim[,2] > 0)


head(dat)
# model check
X = as.matrix(dat[,-1])
head(X)
tail(X)

(p_coef = apply(mod_csim, 2, mean))
head(p_coef)
head(X)

#                         Age b[1] X[3]       isgroup2
llam_hat = p_coef["b0"] + X[,3] * p_coef[1] + X[,2] * p_coef[2]
lam_hat = exp(llam_hat)
hist(lam_hat)

head(dat)
resid = dat$calls - lam_hat*dat$days_active

head(mod_csim)
