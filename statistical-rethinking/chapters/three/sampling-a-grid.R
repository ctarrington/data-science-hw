grid_size <- 1e4
p_grid <- seq(from=0, to=1, length.out=grid_size)
prior <- rep(1, grid_size) # flat weak prior

likelihood <- dbinom(6, size=9, prob=p_grid)
plot(likelihood)

posterior <- likelihood * prior
posterior <- posterior / sum(posterior)

samples <- sample(p_grid, prob=posterior, size=1e4, replace = TRUE)
dens(samples)

direct_from_distribution <- sum(posterior[p_grid < 0.5])
from_sample <- sum(samples < 0.5) / 1e4

middle_eighty <- quantile(samples, c(0.1, 0.9))

# find the limits of a Highest Posterior Density Interval
# smallest part of domain that contains the desired area
# of the probability distribution
limits <- HPDI(samples, prob = 0.8)
sum(posterior[p_grid > limits[1] & p_grid < limits[2]])
sum(samples > limits[1] & samples < limits[2]) / 1e4
