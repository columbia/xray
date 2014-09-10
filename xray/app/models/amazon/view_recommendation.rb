class ViewRecommendation < Snapshot

  field :viewed_product_title
  field :recommended_product_title

  has_context :product_snapshot
end
