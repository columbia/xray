class AmazonAccount < Account

  has_many :product_snapshots
  has_many :recommendation_snapshots

  has_many :recommendations
  has_many :products

end
