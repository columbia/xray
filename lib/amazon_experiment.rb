require 'thread'

class AmazonExperiment

  def initialize(name, tenant, account_percentage)
    @name = name
    @tenant = tenant
    @account_percentage = account_percentage
  end

  def generate_master_account(prod_count)
    master_prods = []
    master_account = Account.new(used: false, is_master: true)
    master_account.save!
    current_count = 0
    prod_count = prod_count == nil ? (+1.0/0.0) : prod_count
    ProductPool.large_distinct_products.each do |prod|
      if current_count < prod_count
        master_prods.push(prod)
        p_snap = ProductSnapshot.new(object:prod, iteration: 1,
                                      account: master_account,
                                      title: prod["title"],
                                      url: prod["url"])
        p_snap.save!
        current_count += 1
      end
    end
    return master_prods
  end

  def generate_accounts(prod_count=nil)
    master_prods = generate_master_account(prod_count)
    #number_of_accounts = ProductPool.distinct_products.length.to_f / @account_percentage
    number_of_accounts = 20
    if prod_count == nil
      products_per_account = ProductPool.distinct_products.length.to_f * @account_percentage
    else
      products_per_account = prod_count * @account_percentage
    end
    puts "products per account #{products_per_account}."
    Mongoid.with_tenant(@tenant) do
      (1..number_of_accounts.to_i).to_a.each do |i|
        p_pool = ProductPool.distinct_products
        used_indexes = Set.new
        new_account = Account.new(used: false, is_master: false)
        new_account.save!
        (1..products_per_account.to_i).to_a.each do |j|
          while new_account.snapshots.length < products_per_account
            index = rand(master_prods.length)
            if !used_indexes.include?(index)
              used_indexes.add(index)
              p_snap = ProductSnapshot.new(object:master_prods[index], iteration: 1,
                                            account: new_account, is_master: true,
                                            title: master_prods[index]["title"],
                                            url: master_prods[index]["url"])
              p_snap.save!
              new_account.snapshots.push(p_snap)
            end
          end
        end
      end
    end
  end

  def run_experiment(account, username, password)
    tries = 0
    try_limit = 10 
    finished = false
    while !finished && tries < try_limit
      tries += 1
      begin
        puts "#{username} #{password}"
        ams = AmazonSession.new(username, password)
        puts "getting product snapshots."
        p_snaps = account.get_product_snapshots()
        puts "got #{p_snaps.length} product snapshots"


        puts "Logging in."
        if !ams.login()
          puts "Failed to log in."
          raise "Captcha Login Failure"
          return false
        end
        begin
          ams.create_wish_list()
        rescue
          puts "Initial wish_list creation failed. Sleeping for 1 min and retry"
          sleep 60
          ams.delete_wishlist("", "")
          puts "Deleted wish list."
          ams.create_wish_list()
        end
        puts "\tAdding #{p_snaps.length} products to wishlist."
        failed_items = 0
        p_snaps.each do |p_snap|
          if ams.add_item_to_wishlist(p_snap)
            puts "\tCollecting product pages."
            ams.collect_product_page_recommendations(p_snap, account, p_snap)
            puts "\tFinished collecting product page recs."
          else
            failed_items += 1
            puts "Item creation failed. #{failed_items}"
          end
          sleep 3
        end
        if failed_items < 2
          puts "Getting recommendations."
          rec_snaps = []
          rec_limit = 5
          rec_tries = 0
          while rec_snaps.length == 0 && rec_tries < rec_limit
            rec_snaps = ams.get_recommendations(account, @tenant)
            rec_tries += 1
            if rec_snaps.length == 0
              puts "Getting recommendations failed."
              sleep 120
            end
          end
          puts "Recevied #{rec_snaps.length} recommendations."
          puts "Total Recommendations: #{RecommendationSnapshot.count}"
          puts "Deleting list"
          ams.delete_wishlist("", "")
          puts "Finished deleting list"
          finished = true
        else
          puts "Generating cart failed do to #{failed_items} failed items."
          raise "ITems Failed."
        end
      rescue
       sleep 300
       puts "Generating cart failed."
      end
    end
    return true
  end

  def run_all_experiments(debug=false)
    Mongoid.with_tenant(@tenant) do
      acc_total = 0
      logins = AmazonHelper.get_amazon_accounts
      login_index = 0
      Account.each do |acc|
        puts acc
        if acc.get_recommendation_snapshots.length == 0 #acc.used == false
          email = logins[login_index]["login"]
          pwd = logins[login_index]["passwd"]
          if debug
            puts "Running debug experiment"
            run_experiment(acc, "ccloudauditor10@gmail.com", "Ad-wiserBarkos")
          else
            puts "running experiment."
            account_failed = run_experiment(acc, email, pwd)
            if account_failed == false
              puts "Getting new account."
              login_index += 1
              login_index = login_index % logins.length
              acc = logins[login_index]
            end
          end
          login_index += 1
          acc.used = true
          acc.save!
          puts "Account: #{acc_total} / #{Account.count}"
          sleep 300
        else
          puts "Account used"
        end
        login_index += 1
        login_index = login_index % logins.length
        acc_total += 1
      end
    end
  end

  def regenerate_all_data(prod_count=nil)
    Mongoid.with_tenant(@tenant) do
      Account.delete_all
      RecommendationSnapshot.delete_all
      ProductSnapshot.delete_all
      BuyRecommendation.delete_all
      ViewRecommendation.delete_all
      generate_accounts(prod_count)
    end
  end

end
