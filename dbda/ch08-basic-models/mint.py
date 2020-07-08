from scipy.stats import beta

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
    
    
class Coin:
  coin_ctr = 0

  def __init__(self, probability, mint_id):
    self.id = Coin.coin_ctr
    Coin.coin_ctr = Coin.coin_ctr + 1
    self.mint_id = mint_id
    self.bernoulli_rv = bernoulli(probability)
    

  def flip(self, target = None):
    response = [self.mint_id, self.id, self.bernoulli_rv.rvs(1)[0]]
    if target is None:
      return response

    target.append(response)
