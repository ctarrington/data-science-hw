from scipy.stats import bernoulli, beta, norm

class Mint:
  mint_ctr = 0

  def __init__(self, mean, std):
    self.id = Mint.mint_ctr
    Mint.mint_ctr = Mint.mint_ctr + 1

    self.rv = norm(mean, std)
    
  def __repr__(self):
    return 'Mint(%r, %r)' % (self.mean, self.std)

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
    
  def __repr__(self):
    return 'Coin(%r, %r)' % (self.probability, self.mint_id)
    

  def flip(self, target = None):
    response = [self.mint_id, self.id, self.bernoulli_rv.rvs(1)[0]]
    if target is None:
      return response

    target.append(response)
