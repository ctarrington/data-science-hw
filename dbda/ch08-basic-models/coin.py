from scipy.stats import bernoulli

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
