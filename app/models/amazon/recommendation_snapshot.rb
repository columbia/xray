require 'graphviz'
require 'ostruct'

class RecommendationSnapshot < Snapshot
  @@amazon_db = "amazon-1"
  @@comment_key = "comment"
  @@recommended_key = "recommended"

  field :recommended
  field :comment
  field :is_wishlist_recommendation

  has_context :product_snapshot

  def self.remove_ellipsis(to_rm)
    begin
      ret_val = to_rm.sub(/\.\s*\.\s*\.\s*$/, '')
    rescue
      ret_val = to_rm
    end
    return ret_val
  end

  def self.fuzzy_contains(collection, to_test)
    to_test_trunc = remove_ellipsis(to_test)
    collection.each do |item|
      if item.start_with?(to_test_trunc)
        return true
      elsif to_test_trunc.start_with?(item)
        return true
      elsif to_test_trunc == item
        return true
      end
    end
    return false
  end

  def self.fuzzy_delete(collection, to_test)
    to_test_trunc = remove_ellipsis(to_test)
    collection.each do |item|
      if item.start_with?(to_test_trunc)
        collection.delete(item)
      elsif to_test_trunc.start_with?(item)
        collection.delete(item)
      elsif to_test_trunc == item
        collection.delete(item)
      end
    end
  end

  def self._has_product_snapshot
    product_titles = Set.new
    in_product = Set.new
    not_in_product = Set.new

    ProductSnapshot.each do |ps|
      product_titles.add(ps.object["title"])
    end

    RecommendationSnapshot.each do |rs|
      comment = rs.object["comment"]
      if fuzzy_contains(product_titles, comment)
        in_product.add(comment)
      else
        not_in_product.add(comment)
      end
    end

    puts "Total Product Snapshots: #{product_titles.length}"
    puts "Ground truth in viewed prodcuts: #{in_product.length}"
    puts "Ground truth not in viewed prodcuts: #{not_in_product.length}"

  end

  def self.has_product_snapshot
    Mongoid.with_tenant(@@amazon_db) do
      _has_product_snapshot
    end
  end

  def self.get_index_or_add(test_arr, item)
    item_index = test_arr.index(item)
    if item_index == nil
      test_arr.push(item)
      item_index = test_arr.index(item)
    end
    return item_index
  end

  def self.get_recommended_by_count(tenant)
    recommended_by = Hash.new
    Mongoid.with_tenant(tenant) do
      RecommendationSnapshot.each do |rs|
        begin
          wish_list_item = remove_ellipsis(rs.get_comment())
        rescue
          wish_list_item = rs.get_comment()
        end
        #wish_list_item = "w_#{wish_list_item}"

        begin
          recommended = remove_ellipsis(rs.get_recommended())
        rescue
          recommended = rs.get_recommended()
        end
        #recommended = "r_#{recommended}"

        if recommended_by.include?(recommended)
          recommended_by[recommended].add(wish_list_item)
        else
          recommended_by[recommended] = Set.new
          recommended_by[recommended].add(wish_list_item)
        end
      end
    end
    recommended_by.each do |k, v|
      recommended_by[k] = v.length
    end
    return recommended_by
  end

  def self.get_recommended_counts
    recommended_by = get_recommended_by_count
    counts = Hash.new 0
    recommended_by.each do |item, count|
      counts[count] += 1
    end
    return counts
  end

  def self.generate_rec_graph(out_dir="/tmp/", out_filename="rec_graph.png")
    colors = ["blue", "red", "green", "orange", "violet", "pink", "teal",
              "lightblue", "lavendar", "gray", "gold", "cyan", "magenta",
              "plum", "black", "darkred", "darkgreen", "darkblue",
              "greenyellow", "grey88", "dimskyblue", "blueviolet", "coral",
              "darkgoldenrod", "darkolivegreen", "darkorange", "royalblue",
              "turquoise", "indigo", "slateblue"]
    recommended_by = []
    recommendations = []
    multi_keys = get_recommended_by_count().select{|k, v| v > 1}.keys
    recommended_by_hash = Hash.new
    print multi_keys.length
    Mongoid.with_tenant(@@amazon_db) do
      RecommendationSnapshot.each do |rs|
        rec_by = rs.get_recommended_by
        rec = rs.get_recommended
        if multi_keys.include?(rec)
          rec_by_index = "c_#{get_index_or_add(recommended_by, rec_by)}"
          rec_index = "r_#{get_index_or_add(recommendations, rec)}"

          if !recommended_by_hash.include?(rec_index)
            recommended_by_hash[rec_index] = Set.new
          end
          recommended_by_hash[rec_index].add(rec_by_index)
        end
      end
    end
    gv = GraphViz.new( :G, :type =>:graph)
    recommended_by_hash.each do |k, v|
      used_edges = Hash.new(Set.new)
      color = colors.pop()
      v.each do |node1|
        v.each do |node2|
          if node1 != node2 and !used_edges[node1].include?(node2) and !used_edges[node1].include?(node2)
            used_edges[node1].add(node2)
            gv.add_edge(node1, node2, :color=>color)
          end
        end
      end
    end
    gv.output( :png => File.join(out_dir, out_filename), :use => :dot)
  end

  def get_recommendation_snapshots_with_account(acc)
    ret_snapshots = []
    Mongoid.with_tenant(@@amazon_db) do
      RecommendationSnapshot.each do |rs|
        if rs.account == account
          ret_snapshots.push(rs)
        end
      end
    end
    return ret_snaphots
  end


  @@coverage_cache = Hash.new(Hash.new(0))
  def self.build_coverage_cache(tenant)
    @@coverage_cache = Hash.new(0)
    Mongoid.with_tenant(tenant) do
      acc_count = 0
      Account.each do |acc|
        prods = Set.new
        acc.get_product_snapshots.each {|ps| prods.add(ps.object.title)}
        acc_count += 1
        puts "Handling: #{acc_count}, #{Account.count}"
      end
    end
  end


  def calculate_coverage()
    accounts_with_data = Set.new()
    accounts_with_rec = Set.new()
    target = get_recommended_by()
    target = RecommendationSnapshot.remove_ellipsis(target)

    Account.each do |acc|
      products = acc.get_product_snapshots()
      recs = acc.get_recommendation_snapshots()

      products.each do |prod|
        title = prod.get_product_title()
        title = RecommendationSnapshot.remove_ellipsis(title)
        if title.start_with?(target)
          accounts_with_data.add(acc)
        end
      end

      recs.each do |rec|
        rec_title = rec.get_recommended()
        rec_title = RecommendationSnapshot.remove_ellipsis(rec_title)
        if rec_title == get_recommended() && accounts_with_data.include?(acc)
          accounts_with_rec.add(acc)
        end
      end
    end
    return accounts_with_rec.length.to_f() / accounts_with_data.length.to_f()
  end

  def signatures
    return super if super
    self.object.values.uniq
  end

  def get_comment
    return self.object[@@comment_key]
  end

  def get_recommended_by
    return RecommendationSnapshot.remove_ellipsis(get_comment)
  end

  def get_recommended
    return RecommendationSnapshot.remove_ellipsis(self.object[@@recommended_key])
  end

  def self.does_recommend(rec1, rec2)
    return rec1.start_with?(rec2) || rec2.start_with?(rec1)
  end


  def self.all_calculate_coverages(tenant, out_path=nil)
    used_recs = Set.new
    if out_path == nil
      out_path = File.join(Rails.root, "data", "amazon", "coverage")
    end
    out_file = File.open(out_path, "w")
    current_rec = 0
    Mongoid.with_tenant(tenant) do
      RecommendationSnapshot.each do |rec_snap|
        current_rec +=1
        rec = rec_snap.get_recommended()
        rec_by = rec_snap.get_recommended_by()
        if !used_recs.include?(rec)
          puts "#{current_rec} / #{RecommendationSnapshot.count}"
          used_recs.add(rec)
          coverage = rec_snap.calculate_coverage()
          puts "Coverage: #{coverage}\n"
          out_file.write("#{coverage}\n")
          out_file.flush()
        end
      end
    end
    out_file.close()
  end

  def self.get_all_recommended_by(recommended_item)
    rec_by = Set.new
    RecommendationSnapshot.each do |rsnap|
      if rsnap.get_recommended() == recommended_item
        rec_by.add(rsnap.get_recommended_by())
      end
    end
    return rec_by
  end

end
