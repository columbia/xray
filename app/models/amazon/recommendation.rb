class Recommendation < SnapshotCluster
  cluster_of :recommendation_snapshots

  def get_all_wish_list_items
    rec_set = Set.new
    snapshots.each do |snap|
      rec_set.add(snap.get_recommended_by())
    end
    puts "\n---"
    rec_set.each do |rec|
      puts rec
    end
    puts "---"

    return rec_set
  end

  targeted_by Product

  # p = p(rec | linked item in the cart)
  # q = p(rec | linked item not in the cart)
  # r = p(random ad shown)
  set_params :context, { :p => 0.98, :q => 0.01, :r => 0.01 }
  #set_params :behavior, { :p => 0.98, :q => 0.01, :r => 0.01 }
  set_params :behavior, {:p=>0.035617523114799765, :q=>0.0013627269944197695, :r=>0.0001}
  # set_params :bool_behavior, {:p=>0.03614589165765133, :q=>0.0013232495521458567, :r=>0}
  set_params :bool_behavior, { :p => 0.98, :q => 0.01, :r => 0.01 }

  set_params :bool_behavior_new, { :threshold               => 0.92,
                                   :min_active_accounts     => 3,
                                   :max_results_size        => 0,
                                   :check_combination       => true,
                                   :variable_threshold      => 0.0,
                                   :stand_out               => [0,0],
                                   :check_inactive_accounts => false}
end
