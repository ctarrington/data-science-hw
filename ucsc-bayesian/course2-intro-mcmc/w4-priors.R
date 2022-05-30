
# messing about with priors and feeding the graph
n_sim = 500
alpha_pri = rexp(n_sim, rate=0.5)
beta_pri = rexp(n_sim, rate=5.0)

mu_pri = alpha_pri/beta_pri
sig_pri = sqrt(alpha_pri/beta_pri^2)

# make 5 lambdas for 5 groups
(lam_pri = rgamma(n=5, shape=alpha_pri[1:5], rate=beta_pri[1:5]))

y_pri = rpois(n=150, lambda=rep(lam_pri, each=30))

locations = rep(1:5, each=30)
boxplot(y_pri ~ locations)

summary(mu_pri)
hist(mu_pri[mu_pri < 50]) 

summary(sig_pri)
hist(sig_pri[sig_pri < 50]) 

summary(lam_pri)
hist(lam_pri[lam_pri<50])
