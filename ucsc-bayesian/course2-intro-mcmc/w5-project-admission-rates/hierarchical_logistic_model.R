library(rjags)
source("create_data.R")

dat = create_data()

# JAGS model
mod_string = " model {
    for (i in 1:length(accepted)) {
        accepted[i] ~ dbern(p[i])
        logit(p[i]) = b_department[department[i]+1] + b_gender[department[i]+1]*gender[i] 
    }
    
    for (j in 1:6) {
      b_gender[j] ~ ddexp(0.0, sqrt(2.0)) 
      b_department[j] ~ ddexp(0.0, sqrt(2.0)) 
    }
} "

set.seed(92)

data_jags = list(accepted=dat$accepted, gender=dat$gender, department=dat$department)
mod = jags.model(textConnection(mod_string), data=data_jags, n.chains=3)
update(mod, 1e3)

params = c("b_gender", "b_department")
mod_sim = coda.samples(model=mod, variable.names=params, n.iter=5e3)
mod_csim = as.mcmc(do.call(rbind, mod_sim))

## convergence diagnostics
plot(mod_sim, ask=TRUE)

gelman.diag(mod_sim)
autocorr.diag(mod_sim)
autocorr.plot(mod_sim)
effectiveSize(mod_sim)

## calculate DIC
dic = dic.samples(mod, n.iter=1e3)
dic

summary(mod_sim)
# male is 0
# slope b[1] is slightly positive, so a slight increase for moving to female...
# dic of 5278

# Prediction
(pm_coef = colMeans(mod_csim))
pm_Xb = pm_coef[dat$department+1] + pm_coef[6 + dat$department+1] * dat$gender
phat = 1.0 / (1.0 + exp(-pm_Xb))
# convert phat to 0 or 1
predicted_accepted = phat > 0.5
(table_0.5 = table(predicted_accepted, dat$accepted) )
sum(diag(table_0.5)) / sum(table_0.5)
# predictions are right 71% of the time