class ProductPair < SnapshotClusterPair
  has_items :product

  field :log_distance
  field :proportional_distance

  def matching_truth
    p_snap1 = e1.snapshots.first.title rescue ''
    p_snap2 = e2.snapshots.first.title rescue ''
    return ProductPool.same_group?(p_snap1, p_snap2)
  end

  def self.redo_matching(threshold)
    Product.delete_all
    ProductPair.delete_all
    Product.do_clustering
    RecommendationSnapshot.set_context_clusters
    Product.recompute_log_footprints
    ProductPair.log_distances
    ProductPair.cluster(threshold)
  end
end
