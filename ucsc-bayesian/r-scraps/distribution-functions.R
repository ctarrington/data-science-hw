successes <- seq(1,10)
probabilities <- dbinom(successes, 10, 0.30)
probabilities <- probabilities / sum(probabilities)
plot(probabilities, main="d<distribution> shows the probability density ")

successes <- seq(1,10)
cumulative_probabilities <- pbinom(successes, 10, 0.30)
cumulative_probabilities <- cumulative_probabilities / sum(cumulative_probabilities)
plot(cumulative_probabilities, main="p<distribution> shows the cumulative probability function ")

# 90% of the probability is between 1 and 5 successes
qbinom(c(0.05, 0.95), 10, 0.30)
