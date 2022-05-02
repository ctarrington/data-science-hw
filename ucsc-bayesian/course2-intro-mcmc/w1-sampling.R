n = 20*1000
sample_thetas = rbeta(n, 5, 3)
expectation_theta = sum(sample_thetas) / n

sample_odds_denominator = 1 - sample_thetas
sample_odds = sample_thetas / sample_odds_denominator

sample_odds_greater_than_one = sum(sample_odds > 1) / n

expectation_odds = sum(sample_odds)/n


theoretical_odds = expectation_theta / (1-expectation_theta)

