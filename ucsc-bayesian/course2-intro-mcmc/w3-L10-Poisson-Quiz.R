#1 
beta0 = 1.5
beta1 = -0.3
beta2 = 1.0

x1 = 0.8
x2 = 1.2

(log_lambda_pred = beta0 + beta1 * x1 + beta2 *x2)
lambda_pred = exp(log_lambda_pred) 

betas = c(1.5, -0.3, 1.0)
xs = c(1, 0.8, 1.2)
llp = betas %*% xs
lp= exp(llp) 

#4 p(k<22) for poisson with lambda = 30
p = ppois(21, 30) # need 21 as parameter is for <=

size = 1e8
sample_ks = rpois(size, 30)
mean(sample_ks < 22)
