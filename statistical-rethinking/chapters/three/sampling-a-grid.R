grid_size <- 1e4
p_grid <- seq(from=0, to=1, length.out=grid_size)
prior <- rep(1, grid_size) # flat weak prior

likelihood <- dbinom(6, size=9, prob=p_grid)
plot(likelihood)

posterior <- likelihood * prior
plot(posterior)
posterior <- posterior / sum(posterior)
plot(posterior)

samples <- sample(p_grid, prob=posterior, size=1e5, replace = TRUE)
plot(samples)
hist(samples)
plot(density(samples))

