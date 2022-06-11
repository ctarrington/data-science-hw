library(rjags)
source("create_data.R")

run_hierarchical_bernoulli_model = function() {
  dat = create_data()
  
  # JAGS model
  mod_string = " model {
      for (i in 1:length(accepted)) {
          accepted[i] ~ dbern(theta_department_gender[department[i]+1, gender[i]+1])
      }
      
      for (j in 1:6) {
        for (k in 1:2) {
          theta_department_gender[j,k] ~ dbeta(2,2)
        } 
      }
  } "
  
  set.seed(92)
  
  data_jags = list(accepted=dat$accepted, gender=dat$gender, department=dat$department)
  mod = jags.model(textConnection(mod_string), data=data_jags, n.chains=3)
  update(mod, 1e3)
  
  params = c("theta_department_gender")
  mod_sim = coda.samples(model=mod, variable.names=params, n.iter=5e3)
  mod_csim = as.mcmc(do.call(rbind, mod_sim))
  
  pm_coef = colMeans(mod_csim)
  
  # build a frame with the thetas from the model's coefficients
  model_thetas = tibble(
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
      model_admission_rate = pm_coef[(gender_index-1)*6 + department_index]
      
      model_thetas = model_thetas %>% add_row(Dept = Dept, Gender = Gender, model_admission_rate = model_admission_rate)
    }
  }
  
  return(list("pm_coef" = pm_coef, "mod_csim" = mod_csim, "model_thetas" = model_thetas))
}
