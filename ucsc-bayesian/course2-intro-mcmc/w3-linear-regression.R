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

