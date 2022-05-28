library("COUNT")
library("rjags")

data("badhealth")
?badhealth
head(badhealth)

any(is.na(badhealth))

#eda
hist(badhealth$numvisit)
sum(badhealth$numvisit == 0)/length(badhealth$numvisit)
# about 32% with no visits

sum(badhealth$badh == 1) / length(badhealth$numvisit)
# about 10% reporting bad health

plot(log(numvisit) ~ age, data=badhealth, subset=badh==0,xlab="age", ylab="log numvisit")
points(log(numvisit) ~ age, data=badhealth, subset=badh==1,col="red")


# build a model for jags
mod_string = " model {
    for (i in 1:length(numvisit)) {
        numvisit[i] ~ dpois(lam[i])
        log(lam[i]) = int + b_badh*badh[i] + b_age*age[i] + b_intx*age[i]*badh[i]
    }
    
    int ~ dnorm(0.0, 1.0/1e6)
    b_badh ~ dnorm(0.0, 1.0/1e4)
    b_age ~ dnorm(0.0, 1.0/1e4)
    b_intx ~ dnorm(0.0, 1.0/1e4)
} "

set.seed(102)

data_jags = as.list(badhealth)

params = c("int", "b_badh", "b_age", "b_intx")

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

# model check
X = as.matrix(badhealth[,-1])
X = cbind(X, with(badhealth, badh*age))
head(X)
tail(X)

(pmed_coef = apply(mod_csim, 2, median))
llam_hat = pmed_coef["int"] + X %*% pmed_coef[c("b_badh", "b_age", "b_intx")]
lam_hat = exp(llam_hat)
hist(lam_hat)

resid = badhealth$numvisit - lam_hat
plot(resid) # the data were ordered
plot(lam_hat, badhealth$numvisit)
abline(0.0, 1.0)

plot(lam_hat[which(badhealth$badh==0)], resid[which(badhealth$badh==0)], xlim=c(0, 8), ylab="residuals", xlab=expression(hat(lambda)), ylim=range(resid))
points(lam_hat[which(badhealth$badh==1)], resid[which(badhealth$badh==1)], col="red")

var(resid)
var(resid[which(badhealth$badh==0)])
var(resid[which(badhealth$badh==1)])
# so, we question the fit based on the DIC and the variance within group being higher than overall


summary(mod_sim)
summary(mod_csim) # same

# the advantage of mcmc is that it gives us a posterior that we can
# use to answer questions...

# holding age at 35, what is the posterior probability that a person in
# who reports poor health will have more visits?

x1 = c(0, 35, 0) # good health, age, interaction
x2 = c(1, 35, 35) # bad health, age, interation

head(mod_csim)
reordered_columns = c(2,1,3)
# find the log lambdas
loglam1 = mod_csim[,"int"] + mod_csim[, reordered_columns] %*% x1
loglam2 = mod_csim[,"int"] + mod_csim[, reordered_columns] %*% x2

# recover the lambdas
lam1 = exp(loglam1)
lam2 = exp(loglam2)

hist(lam1)
hist(lam2)

# simulate number of visits
n_sim = length(lam1)
y1 = rpois(n=n_sim, lambda = lam1)
y2 = rpois(n=n_sim, lambda = lam2)

plot(table(factor(y1, levels=0:18))/n_sim, pch=2, ylab="posterior prob.", xlab="visits")
points(table(y2+0.1)/n_sim, col="red")

mean(y2 > y1)
