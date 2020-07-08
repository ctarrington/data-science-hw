class Mint:
  mint_ctr = 0

  def __init__(self, mean, std):
    self.id = Mint.mint_ctr
    Mint.mint_ctr = Mint.mint_ctr + 1

    var = std * std
    shape1 = ((1 - mean) / var - 1 / mean) * mean ** 2
    shape2 = shape1 * (1 / mean - 1)
    self.rv = beta(shape1, shape2)

  def make_coins(self, count, target = None):
    probabilities = self.rv.rvs(count)
    coins = [Coin(p, self.id) for p in probabilities]

    if target is None:
      return coins

    target.extend(coins)
