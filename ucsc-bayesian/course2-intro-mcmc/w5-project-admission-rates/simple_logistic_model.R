library(rjags)
source("create_data.R")

dat = create_data()

# JAGS model
mod_string = " model {
    for (i in 1:length(accepted)) {
        accepted[i] ~ dbern(p[i])
        logit(p[i]) = int + b[1]*gender[i] + b[2]*department[i] 
    }
    int ~ dnorm(0.0, 1.0/25.0)
    for (j in 1:2) {
        b[j] ~ ddexp(0.0, sqrt(2.0)) # has variance 1.0
    }
} "

set.seed(92)

data_jags = list(accepted=dat$accepted, gender=dat$gender, department=dat$department)

params = c("int", "b")

mod = jags.model(textConnection(mod_string), data=data_jags, n.chains=3)
update(mod, 1e3)

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
pm_Xb = pm_coef["int"] + dat$department * pm_coef[2] + dat$gender * pm_coef[1]
phat = 1.0 / (1.0 + exp(-pm_Xb))
# convert phat to 0 or 1
predicted_accepted = phat > 0.5
(table_0.5 = table(predicted_accepted, dat$accepted) )
sum(diag(table_0.5)) / sum(table_0.5)
# predictions are right 71% of the time


# extraction of thetas
extracted_thetas = tibble(
  Dept = character(),
  Gender = character(),
  model_admission_rate = numeric()
  )

genders = c("Male", "Female")
departments = c("A", "B", "C", "D", "E", "F")

for (department_index in seq(1,6)) {
  for (gender_index in seq(1,2)) {
    Dept = departments[department_index]
    Gender = genders[gender_index]
    
    pm_Xb = pm_coef["int"] + (department_index-1) * pm_coef[2] + (gender_index-1) * pm_coef[1]
    model_admission_rate = 1.0 / (1.0 + exp(-pm_Xb))
    
    extracted_thetas = extracted_thetas %>% add_row(Dept = Dept, Gender = Gender, model_admission_rate = model_admission_rate)
  }
}

extracted_thetas
