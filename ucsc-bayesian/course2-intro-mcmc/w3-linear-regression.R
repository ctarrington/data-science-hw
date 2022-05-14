library("rjags")
library("car")
data("Leinhardt")

#eda 
plot(infant ~ income, data = Leinhardt)
hist(Leinhardt$income)
hist(Leinhardt$infant)
# definitely not linear

Leinhardt$loginfant = log(Leinhardt$infant)
Leinhardt$logincome = log(Leinhardt$income)

plot(loginfant ~ logincome, data = Leinhardt)
hist(Leinhardt$logincome)
hist(Leinhardt$loginfant)
# looks like infant mortality is proportional to income^a for some negative a

# model it
cleaned = na.omit(Leinhardt)

lmod = lm(loginfant ~ logincome, data = cleaned)
summary(lmod)

plot(loginfant ~ logincome, data = Leinhardt)
abline(lmod)

#
# use JAGS
mod1_string = " model {
    for (i in 1:n) {
        y[i] ~ dnorm(mu[i], prec)
        mu[i] = b[1] + b[2]*log_income[i] 
    }
    
    for (i in 1:2) {
        b[i] ~ dnorm(0.0, 1.0/1.0e6)
    }
    
    prec ~ dgamma(5/2.0, 5*10.0/2.0)
    sig2 = 1.0 / prec
    sig = sqrt(sig2)
} "

set.seed(72)
data1_jags = list(y=cleaned$loginfant, n=nrow(cleaned), 
                  log_income=cleaned$logincome)

params1 = c("b", "sig")

inits1 = function() {
  inits = list("b"=rnorm(2,0.0,100.0), "prec"=rgamma(1,1.0,1.0))
}

mod1 = jags.model(textConnection(mod1_string), data=data1_jags, inits=inits1, n.chains=3)
update(mod1, 1000) # burn-in

mod1_sim = coda.samples(model=mod1,
                        variable.names=params1,
                        n.iter=5000)

mod1_csim = do.call(rbind, mod1_sim) # combine multiple chains
summary(mod1_csim)

plot(mod1_sim)
gelman.diag(mod1_sim)
gelman.plot(mod1_sim)
autocorr.diag(mod1_sim)
autocorr.plot(mod1_sim)
effectiveSize(mod1_sim)
summary(mod1_sim)

# compare to lmod
summary(lmod)

# how do you evaluate a model from the residuals?
# what does it look like if you pick the wrong model
nolog_mod = lm(infant ~ income, data = cleaned)

plot(resid(nolog_mod)) # to check independence (looks okay)
plot(predict(nolog_mod), resid(nolog_mod)) # to check for linearity, constant variance (looks bad)
qqnorm(resid(nolog_mod)) # to check Normality assumption (we want this to be a straight line)
# so our eyes did not betray us - linear is the wrong model to fit

# how did we do with y=x^a ??
# We want to compare the residual between each actual value
# and the predicted value from the model

# we want to do vector math for infant_predicted = b1 + b2 * income_data
# maybe stare at the pieces of this for a minute...
X = cbind(rep(1.0, data1_jags$n), data1_jags$log_income)

pm_params1 = colMeans(mod1_csim) # posterior mean

# multiply for each row to get a predicted value for log(infant mortality)
yhat1 = drop(X %*% pm_params1[1:2])
resid1 = data1_jags$y - yhat1
plot(resid1) # against data index
qqnorm(resid1) # checking normality of residuals

plot(yhat1, resid1) # against predicted values
plot(predict(lmod), resid(lmod)) # to compare with reference linear model
plot(predict(nolog_mod), resid(nolog_mod)) # to compare with no log linear model

