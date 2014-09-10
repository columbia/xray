require 'descriptive_statistics'

class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  field :used

  field :is_master

  field :login

  has_many :snapshots

  has_many :account_snapshot_clusters, dependent: :destroy


  @recommendation_snapshots = []
  @product_snapshots = []

  # creates class methods to access snapshots
  # and cluster relationships
  items = %w(ad email product recommendation)
  items.map do |item|
    sn_name = "#{item}_snapshot"
    define_method(sn_name.pluralize) { snapshots.where(_type: sn_name.classify) }
    rel_name = "account_#{item}"
    define_method(rel_name.pluralize) { account_snapshot_clusters.where(_type: rel_name.classify) }
  end

  def self.get_amazon_accounts
    ps_label = "ps"
    rs_label = "rs"
    ret_accounts = Hash.new()

    Mongoid.with_tenant("amazon-1") do
      ProductSnapshot.each do |ps|
        acc = ps.account
        if !ret_accounts.include?(acc)
          ret_accounts[acc] = Hash.new()
          ret_accounts[acc][ps_label] = Set.new()
          ret_accounts[acc][rs_label] = Set.new()
        end
        ret_accounts[acc][ps_label].add(ps)
      end
      RecommendationSnapshot.each do |rs|
        acc = rs.account
        if !ret_accounts.include?(acc)
          ret_accounts[acc] = Hash.new()
          ret_accounts[acc][ps_label] = Set.new()
          ret_accounts[acc][rs_label] = Set.new()
        end
        ret_accounts[acc][rs_label].add(rs)
      end
    end
    return ret_accounts
  end

  def self.write_amazon_acc_data(datapath, amazon_accs)
    acc_data = []
    amazon_accs.keys().each do |acc|
      acc_id = acc.id
      ps_count = amazon_accs[acc]["ps"].length
      rs_count = amazon_accs[acc]["rs"].length
      acc_data.push([acc_id, ps_count, rs_count].join(" "))
    end
    data_file = File.open(datapath, "w")
    data_file.write(acc_data.join("\n"))
    data_file.close()

  end

  def self.write_amazon_statistics(datapath, amazon_accs)
    rec_prod = Hash.new()
    amazon_accs.keys().each do |acc|
      ps_count = amazon_accs[acc]["ps"].length
      rs_count = amazon_accs[acc]["rs"].length
      if !rec_prod.include?(ps_count)
        rec_prod[ps_count] = []
      end
      rec_prod[ps_count].push(rs_count)
    end

    stat_data = ["count min q1 median q3 max"]
    rec_prod.keys().each do |ps_count|
      desc_stats = rec_prod[ps_count].descriptive_statistics
      data_line = "#{ps_count} #{desc_stats[:min]} #{desc_stats[:q1]} #{desc_stats[:median]} #{desc_stats[:q3]} #{desc_stats[:max]}"
      stat_data.push(data_line)
    end
    puts stat_data
    data_file = File.open(datapath, "w")
    data_file.write(stat_data.join("\n"))
    data_file.close()

  end

  def self.write_amazon_account_data(pathname=File.join(Rails.root, "data/amazon"))
    xy_filename = "amazon_acc.dat"
    stats_filename = "amazon_acc_stats.dat"
    amazon_accs = Account.get_amazon_accounts

    write_amazon_acc_data(File.join(pathname, xy_filename), amazon_accs)
    write_amazon_statistics(File.join(pathname, stats_filename), amazon_accs)
  end

  def self.get_wish_list_permuations
    combinations = Hash.new()
    amazon_accs = get_amazon_accounts()

    amazon_accs.keys().each do |acc|
      ps_ids = amazon_accs[acc]["ps"].collect{|x| x._id}.sort()
      if !combinations.include?(ps_ids.length)
        combinations[ps_ids.length] = Set.new()
      end
      combinations[ps_ids.length].add(Set.new(ps_ids))
      puts ps_ids
    end
    return combinations
  end

  def get_product_snapshots()
    p_snaps = []
      snapshots.each do |snap|
        if snap.class == ProductSnapshot
          p_snaps.push(snap)
        end
      end
      return p_snaps
  end

  def get_recommendation_snapshots()
    if @recommendation_snapshots == nil || @recommendation_snapshots.length == 0
      @recommendation_snapshots = []
      snapshots.each do |snap|
        if snap.class == RecommendationSnapshot
          @recommendation_snapshots.push(snap)
        end
      end
    end
    return @recommendation_snapshots
  end

  def reset_snapshot_caches()
    @recommendation_snapshots = []
    @product_snapshots = []
  end

  def has_cluster?(cluster_id)
    AccountSnapshotCluster.where( account: self, snapshot_cluster_id: cluster_id ).count > 0
  end

  def self.master_account
    exp = Experiment.where( :name => Mongoid.tenant_name ).first
    if exp == nil
      Account.where(:is_master => true).first
    else
    Account.where( id: exp.master_account ).first
    end
  end
end
