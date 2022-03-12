library(ggplot2)

rm(list=ls())
dev.off()

# set up a grid of parameters
# w is the proportion of globe that is covered in water

grid_size <- 1e2
w_grid <- seq(from=0, to=1, length.out=grid_size)
prior <- rep(1, grid_size) # flat weak prior

apply_data <- function(prior, number_of_waters) {
  likelihood <- dbinom(number_of_waters, size=1, prob=w_grid)
  posterior <- likelihood * prior
  posterior <- posterior / sum(posterior)
  
  plot(x=w_grid, y=prior, col='blue')
  points(x=w_grid, y=posterior)
  
  return(posterior)
}

current <- apply_data(prior, 1)


current <- apply_data(current, 0)
current <- apply_data(current, 1)
current <- apply_data(current, 1)
current <- apply_data(current, 1)
current <- apply_data(current, 0)
current <- apply_data(current, 1)
current <- apply_data(current, 0)
current <- apply_data(current, 1)


#samples <- sample(w_grid, prob=posterior, size=1e5, replace = TRUE)
#dens(samples)

