class Product < SnapshotCluster

  cluster_of :product_snapshots
  has_signature :recommendation

  def get_all_products
    prod_set = Set.new
    snapshots.each do |snap|
      prod_set.add(snap.get_product_title)
    end
    puts "\n---"
    prod_set.each do |prod|
      puts prod
    end
    puts "---"
    return prod_set
  end

  def self.label_all_snapshot_with_match_group
    Product.each do |p|
      p.snapshots.each do |sn|
        sn.tmp_match_group = p.match_group
        sn.save
      end
    end
  end

end

