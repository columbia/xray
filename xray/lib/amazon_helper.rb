require 'mechanize'
require 'descriptive_statistics'

class AmazonHelper
  @@food_cluster = [
    "Cuisinart GR-4N 5-in-1 Griddler",
    "Norpro Cut-N-Slice Flexible Cutting Boards, Set of 3",
    "Pyrex Prepware 2-Cup Measuring Cup, Clear with Red Measurements"]
  @@electronics_cluster = [
    "Accell D080B-011K Travel Surge Protector with 612 Joules Dual USB Charging, 3 Outlets, Folding Plug - Black",
    "Panasonic KX-TG7732S DECT 6.0 Link-to-Cell via Bluetooth Cordless Phone with Answering System, Silver, 2 Handsets",
    "Ultimate Ears MINI BOOM Wireless Bluetooth Speaker/Speakerphone - Black"]
  @@multi_clusters = @@food_cluster + @@electronics_cluster


  def self.investigate_clusters
    clusters = RecommendationCache.each.select{|x| x.recommended_by.length > 1}
    clusters = clusters.map{|x| x.recommended_item}

    clusters.each do |clust|
      rec_by_counts = Hash.new(0)
      RecommendationSnapshot.each do |r_snap|
        rec = r_snap.get_recommended()
        if clust.starts_with?(rec) || rec.start_with?(clust)
          rec_by = r_snap.get_recommended_by()
          rec_by_counts[rec_by] += 1
        end
      end
      puts clust
      puts "\t#{rec_by_counts}"
      puts "---"
    end
  end

  def self.prune_clusters
    RecommendationCache.clear_cache
    elec_1 = @@electronics_cluster[0]
    food_1 = @@food_cluster[0]
    # Removes 2/3 prodcuts from the food and electronics cluster
    RecommendationSnapshot.each do |r_snap|
      rec_by = r_snap.get_recommended_by()
      if @@multi_clusters.include?(rec_by) && rec_by != food_1 &&
        rec_by != elec_1
        puts "Deleting recommendation: #{rec_by}."
        r_snap.delete
      end
    end

    ProductSnapshot.each do |p_snap|
      title = p_snap.get_product_title
      matches_elec = RecommendationSnapshot.does_recommend(title, elec_1)
      matches_food = RecommendationSnapshot.does_recommend(title, food_1)
      if @@multi_clusters.include?(title) && !matches_elec && !matches_food
        puts "Deleting product #{title}"
        p_snap.delete
      end
    end
    RecommendationCache.build_cache
  end

  def self.prepare_missing_rec_by
    # Corrects the missing cuisinart link in recommendations.
    cuisinart = "Cuisinart GR-4N 5-in-1 Griddler"
    amazon_label = "Amazon.com "

    RecommendationCache.clear_cache
    RecommendationSnapshot.each do |r_snap|
      if r_snap.get_recommended_by() == amazon_label
        r_snap.object["comment"] = cuisinart
        r_snap.save
      end
    end
    ProductSnapshot.each do |p_snap|
      if p_snap.get_product_title() == amazon_label
        p_snap.object["title"] = cuisinart
        p_snap.save
      end
    end
    RecommendationCache.build_cache
  end

  def self.clear_amazon_data(tenant)
    Mongoid.with_tenant(tenant) do
      Account.destroy_all
      Product.destroy_all
      ProductSnapshot.destroy_all
      Recommendation.destroy_all
      RecommendationCache.destroy_all
      RecommendationSnapshot.destroy_all
      BuyRecommendation.destroy_all
      ViewRecommendation.destroy_all
    end
  end

  def self.get_acc_combinations_by_acc_size
    size_combinations = Hash.new()
    Account.each do |acc|
      prods = acc.get_product_snapshots().map{|x| x.get_product_title()}.sort
      p_size = prods.length
      if !size_combinations.include?(p_size)
        size_combinations[p_size] = Set.new
      end
      size_combinations[p_size].add(prods)
    end
    return size_combinations
  end

  def self.get_failed_item_count(failed_items)
    failed_counts = Hash.new(0)
    Account.each do |acc|
      prods = acc.get_product_snapshots.map{|x| x.get_product_title()}
      prods.each do |prod|
        if failed_items.include?(prod)
          failed_counts[prod] += 1
        end
      end
    end

    prod_counts = Hash.new()
    Account.each do |acc|
      prods = acc.get_product_snapshots.map{|x| x.get_product_title()}
      prods.each do |prod|
        if !prod_counts.include?(prod)
          prod_counts[prod] = Hash.new(0)
        end
        prod_counts[prod][prods.length] += 1
      end
    end
    prod_counts.each do |item, counts|
      print "\"#{item}\" "
      counts.keys.sort.each do |count|
        print "#{counts[count]} "
      end
      puts ""
    end
    return failed_counts
  end

  def self.get_item_count
    item_counts = Hash.new(0)
    Account.each do |acc|
      prods = acc.get_product_snapshots.map{|x| x.get_product_title()}
      prods.each do |prod|
        item_counts[prod] += 1
      end
    end
    return item_counts
  end

  def self.prods_by_account
    prod_hash = Hash.new(0)
    Account.each do |acc|
      acc_set = Set.new
      prod_shots = acc.get_product_snapshots()
      prod_shots.each do |p_shot|
        acc_set.add(p_shot.get_product_title)
      end
      acc_set.each do |p_title|
        prod_hash[p_title] += 1
      end
    end
    return prod_hash
  end

  def self.appears_with_other_cluster
    ret_hash = {}
    test_clusters = [@@electronics_cluster, @@food_cluster]
    test_clusters.each do |cluster|
      target_item = cluster[0]
      cluster_hash = Hash.new(0)
      Account.each do |acc|
        products = acc.get_product_snapshots().map{|x| x.get_product_title()}
        if products.include?(target_item)
          cluster[1..cluster.length].each do |c_item|
            if products.include?(c_item)
              cluster_hash[c_item] += 1
              cluster_hash["#{c_item}_#{products.length}"] += 1
            end
          end
          contains_all = true
          cluster[1..cluster.length].each do |c_item|
            if !products.include?(c_item)
              contains_all = false
            end
          end
          if contains_all
            cluster_hash["both"] += 1
            cluster_hash["both_#{products.length}"] += 1
          end
        end
      end
      puts "---#{target_item}---"
      puts cluster_hash
      ret_hash[target_item] = cluster_hash
    end
    return ret_hash
  end

  def self.cluter_targeting
    ret_hash = Hash.new
    test_clusters = [@@electronics_cluster, @@food_cluster]
    test_clusters.each do |cluster|
      rec_hash = Hash.new(0)
      target_item = cluster[0]
      RecommendationCache.each do |rec_cache|
        rec_by = rec_cache.recommended_by
        contains_all = true
        if rec_by.include?(target_item)
          cluster[1..cluster.length].each do |c_item|
            if rec_by.include?(c_item)
              rec_hash[c_item] += 1
            else
              contains_all = false
            end
          end
          if contains_all
            rec_hash["all"] += 1
          end
        end
      end
        puts ">>#{target_item}<<"
        puts rec_hash
        ret_hash[target_item] = rec_hash
    end
    return ret_hash
  end

  @@account_creation_url = "https://www.amazon.com/ap/register?ie=UTF8&openid.pape.max_auth_age=0&openid.ns.pape=http%3A%2F%2Fspecs.openid.net%2Fextensions%2Fpape%2F1.0&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&_encoding=UTF8&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.mode=checkid_setup&openid.assoc_handle=usflex&openid.return_to=https%3A%2F%2Fwww.amazon.com%2Fgp%2Fyourstore%2Fhome%3Fie%3DUTF8%26ref_%3Dgno_newcust"

  def self.get_account_creation_mech(email)
    mech = Mechanize.new
    mech.user_agent_alias = "Linux Mozilla"
    mech.log = Logger.new File.join(Rails.root, "log", "amazon_create_#{email}.log")

    return mech
  end

  def self.is_created(created_page, email)
    created_regex = /We currently don't have any personalized recommendations for you/
    if created_regex.match(created_page.body) != nil
      puts "Created account: #{email}."
      return true
    else
      puts "ERROR: failed to create: #{email}."
      return false
    end
  end

  def self.create_account(email, password, name)
    mech = get_account_creation_mech(email)
    creation_page = mech.get(@@account_creation_url)
    sleep 60
    creation_page.save!("/tmp/account_creation_#{email}.html")
    creation_form = creation_page.form_with(:id => "ap_register_form")
    creation_form["customerName"] = name
    creation_form["email"] = email
    creation_form["emailCheck"] = email
    creation_form["password"] = password
    creation_form["passwordCheck"] = password
    created_page = creation_form.submit()
    created_page.save!("/tmp/account_created_#{email}.html")
    is_created = is_created(created_page, email)
  end

  def self.get_amazon_accounts
    accs = []
    # out accounts
    return accs
  end

  def self.create_accounts(name)
    accs = get_amazon_accounts
    accs.each do |acc_hash|
      email_account = acc_hash["login"]
      email_password = acc_hash["passwd"]
      puts "\nCreating account: #{email_account}."
      create_account(email_account, email_password, "J. Bronson")
      sleep 300
    end
  end

  def self.print_recommendations_multiple_ground_truths
    rec_counts = Hash.new(Set.new)
    RecommendationSnapshot.each do |r_snap|
      rec = r_snap.get_recommended
      rec_by = r_snap.get_recommended_by()
      if !rec_counts.include?(rec)
        rec_counts[rec] = Set.new
      end
      rec_counts[rec].add(rec_by)
    end
    counts = rec_counts.map{|k,v| v.length}
    counter = Hash.new(0)
    counts.each do |x|
      counter[x] += 1
    end
    puts counter
    #rec_counts = rec_counts.select{|k,v| v.length > 1}
    #puts rec_counts
  end

  @@master_recommendations = Set.new
  def self.build_master_set
    master_account = Account.where(:is_master => true).first
    if master_account != nil
      master_account.get_recommendation_snapshots().each do |r_snap|
        @@master_recommendations.add(r_snap.get_recommended())
      end
    end
  end

  def self.recommendation_occurs_in_master(rec_title)
    if @@master_recommendations.length == 0
      build_master_set()
    end
    return @@master_recommendations.include?(rec_title)
  end

  @@master_rec_by = Hash.new
  def self.build_master_rec_by
    master_account = Account.where(:is_master => true).first
    if master_account != nil
      master_account.get_recommendation_snapshots().each do |r_snap|
        rec_title = r_snap.get_recommended()
        rec_by_title = r_snap.get_recommended_by()
        if !@@master_rec_by.include?(rec_title)
          @@master_rec_by[rec_title] = Set.new
        end
        @@master_rec_by[rec_title].add(rec_by_title)
      end
    end
  end

  def self.get_recommended_by_in_master(rec_title)
    if !@@master_rec_by.include?(rec_title)
      build_master_rec_by()
    end
    if @@master_rec_by.include?(rec_title)
      return @@master_rec_by[rec_title].to_a
    else
      return []
    end
  end

  def self.write_unique_recs_per_account(tenant)
    recs_per_account = []
    rec_titles = Set.new
    Mongoid.with_tenant(tenant) do
      Account.each do |acc|
        if !acc.is_master
          rec_snaps = acc.get_recommendation_snapshots()
          rec_snaps.each do |r_snap|
            rec_titles.add(r_snap.get_recommended())
          end
          puts "#{recs_per_account.size()} #{rec_titles.size()}"
          recs_per_account.push(rec_titles.size())
        end
      end
    end
  end

  def self.extract_title(rec)
    if rec.include?("span")
      span_reg = /<\s*span\s+title\s*=\s*"(.*)"/
      span_match = span_reg.match(rec)
      if span_match != nil
        return span_match[1]
      else
        puts "nil match"
        return rec
      end
    else
      return rec
    end
  end

  def self.get_view_recommendations(product_page, div_id)
    return_recs = Set.new
    session_div = product_page.search("//div[@id='#{div_id}']")
    li = session_div.search("//li")
    view_recs = li.search("//div[starts-with(@class, 'new-faceout')]")[0..5].map{|vr| vr.element_children().first()}
    view_recs.each do |vr|
      rec = vr.to_s.split("\n").last.gsub(/^\s*/, "").gsub(/\s*<\/a>\s*$/, "")
      puts extract_title(rec)
      return_recs.add(extract_title(rec))
    end
    return return_recs
  end

  def self.test_get_view_recs(url)
    mech = Mechanize.new
    mech.user_agent_alias = "Linux Mozilla"
    product_page = mech.get(url)
    puts get_view_recommendations(product_page, "purchaseShvl").length
    puts get_view_recommendations(product_page, "sessionShvl").length
  end

  def self.print_buy_view_rec_overlap(tenant)
    rec_set = Set.new
    r_snap_set = Set.new
    Mongoid.with_tenant(tenant) do
      BuyRecommendation.each{|br| rec_set.add(clean_up_rec_title(br.recommended_product_title))}
      ViewRecommendation.each{|vr| rec_set.add(clean_up_rec_title(vr.recommended_product_title))}

      puts rec_set.length
      RecommendationSnapshot.each do |r_snap|
        rec = r_snap.get_recommended
        if !r_snap_set.include?(rec)
          r_snap_set.add(rec)
          if RecommendationSnapshot.fuzzy_contains(rec_set, rec)
            RecommendationSnapshot.fuzzy_delete(rec_set, rec)
          end
        end
      end
      rec_set.each do |rs|
        puts rs
      end
      puts rec_set.length
    end
  end

  def self.clean_up_rec_title(rec_title)
    # span_reg = /<\s*span\s*title=\\"(.*)\\"/
    if rec_title != nil && rec_title.index("span") != nil
      i1 = rec_title.index("\"")
      if i1 != nil
        i2 = rec_title.index("\"", i1 + 1)
        if i2 != nil
          slice = rec_title.slice(i1 + 1, i2 - 1)
          return slice
        else
          return rec_title
        end
      else
        return rec_title
      end
    else
      return rec_title
    end
  end

  def self.process_product_recs(tenant)
    Mongoid.with_tenant(tenant) do
      br_count = 0
      BuyRecommendation.each do |br|
        rec_title = clean_up_rec_title(br.recommended_product_title)
        obj = {"comment" => br.viewed_product_title,
               "recommended" => rec_title}
        new_r_snap = RecommendationSnapshot.new(recommended: rec_title,
                                                comment: br.viewed_product_title,
                                                object: obj,
                                                account: br.account,
                                                context: br.context)
        new_r_snap.save!
        br_count += 1
        if br_count % 100 == 0
          puts "#{br_count} / #{BuyRecommendation.count}"
        end
      end
      br_count = 0
      ViewRecommendation.each do |vr|
        obj = {"comment" => vr.viewed_product_title,
               "recommended" => vr.recommended_product_title}
        new_r_snap = RecommendationSnapshot.new(recommed: vr.recommended_product_title,
                                                comment: vr.viewed_product_title,
                                                object: obj,
                                                account: vr.account,
                                                context: vr.context)
        br_count += 1
        if br_count % 100 == 0
          puts "#{br_count} / #{ViewRecommendation.count}"
        end
        new_r_snap.save!
      end
    end
  end

  def self.get_sub_tenant(tenant, product_count)
    return "#{tenant}_sub_#{product_count}"
  end

  def self.create_random_experiment(old_tenant, new_tenant, product_count)
    p_snaps = []
    r_snaps = []
    accounts = []
    prod_titles = Set.new
    Mongoid.with_tenant(old_tenant) do
      while prod_titles.length < product_count
        ProductSnapshot.each do |ps|
          if prod_titles.length < product_count && rand(0..10) == 5
            p_title = ps.object["title"]
            puts p_title
            puts prod_titles.length
            prod_titles.add(p_title)
          end
        end
      end
      p_snaps = ProductSnapshot.each.select{|ps| prod_titles.include?(ps.object["title"])}
      accounts = Set.new(p_snaps.map{|ps| ps.account})
    end
    r_snaps = []
    p_snaps = []
    accs = []
    exps = []
    puts "Accounts: #{accounts.length}"
    accounts.each do |acc|
      new_acc = Account.new(:is_master => acc.is_master)
      accs.push(new_acc)

      if new_acc.is_master
        exp = Experiment.new(:name => new_tenant, :master_account => new_acc.id)
        exps.push(exp)
      end

      acc.get_product_snapshots.each do |p_snap|
        if prod_titles.include?(p_snap.object["title"])
          new_p_snap = ProductSnapshot.new(:account => new_acc,
                                           :object => p_snap.object,
                                           :url => p_snap.object["url"],
                                           :title => p_snap.object["title"])
          p_snaps.push(new_p_snap)
        end
      end
      acc.get_recommendation_snapshots.each do |r_snap|
        rec_by = r_snap.get_recommended_by
        if RecommendationSnapshot.fuzzy_contains(prod_titles, rec_by)
          new_r_snap = RecommendationSnapshot.new(:account => new_acc,
                                                  :object => r_snap.object,
                                                  :recommended => r_snap.get_recommended,
                                                  :comment => r_snap.get_recommended_by())
          r_snaps.push(new_r_snap)
        end
      end
    end
    Mongoid.with_tenant(new_tenant) do
      puts "Saving accounts."
      accs.map{|acc| acc.save!}
      puts "p_snaps saving."
      p_snaps.map{|ps| ps.save!}
      puts "r_snaps saving."
      r_snaps.map{|rs| rs.save!}
      puts "exp saving."
      exps.map{|exp| exp.save!}
    end
  end


  def self.create_sub_experiment(tenant, product_count)
    new_tenant = get_sub_tenant(tenant, product_count)
    puts "Clearing data"
    clear_amazon_data(new_tenant)
    puts "Generating experiment."
    create_random_experiment(tenant, new_tenant, product_count)
  end

  def self.write_out_cluster_amount(tenant, acc_counts, out_path)
    Mongoid.with_tenant(tenant) do
      puts "Clustering recommendations."
      Recommendation.do_clustering
      puts "Setting recommendation context clusters."
      Product.do_clustering
      puts "Setting context clusters."
      RecommendationSnapshot.set_context_clusters
    end

    out_data = []
    file = File.open(out_path, "w")
    acc_counts.each do |count|
      precisions = []
      recalls = []
      iterations = 10
      (1..iterations).to_a.each do |iteration|
        puts "Handling count: #{count}"
        prec_rec = Statistics.amazon_clustering(tenant, count)
        prec = prec_rec[0]
        rec = prec_rec[1]
        precisions.push(prec)
        recalls.push(rec)
        puts "#{prec} #{rec}"
      end
      data_line = "#{count} #{precisions.mean} #{recalls.mean} #{precisions.standard_deviation} #{recalls.standard_deviation}"
      puts data_line
      out_data.push(data_line)
      file.write("#{data_line}\n")
    end
    #file.write(out_data.join("\n"))
    file.close()
  end

  def self.create_experiment(tenant)
    max_length = -1
    master_id = 0
    Mongoid.with_tenant(tenant) do
      Account.each do |acc|
        if acc.get_product_snapshots.length > max_length
          max_length = acc.get_product_snapshots.length
          master_id = acc.id
        end
      end
      puts max_length
      puts master_id
      exp = Experiment.new(:name => tenant, :master_account => master_id)
      exp.save!
    end
  end

  def self.correct_missing_recommendations(tenant)
    Mongoid.with_tenant(tenant) do
      RecommendationSnapshot.each do |r_snap|
        acc = r_snap.account
        if acc != nil && !acc.snapshots.include?(r_snap)
          acc.snapshots.push(r_snap)
          acc.save!
        end
        if acc != nil
        puts acc.get_recommendation_snapshots.length
        end
      end
    end
  end

  def self.correct_indexes()
    Mongoid.session(:default)
           .with(database: :admin)
           .command({listDatabases:1})['databases']
           .each do |db|
             Mongoid.override_database(db['name'])
             login_index = 0
             # Correct login index
             Account.each do |acc|
               if acc.class != GoogleAccount
                 acc.login = login_index
                 login_index += 1
                 acc.save!
               end
             end
           end
  end

  def self.groups_per_account(tenant)
    acc_hash = Hash.new
    Mongoid.with_tenant(tenant) do
      Account.each do |acc|
        acc_hash[acc.id] = Hash.new(0)
        acc.get_product_snapshots.each do |ps|
          group = ProductPool.get_product_group(ps.object["title"])
          acc_hash[acc.id][group] += 1
        end
      end
    end
    return acc_hash
  end
end
