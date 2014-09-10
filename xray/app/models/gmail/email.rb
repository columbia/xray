class Email < SnapshotCluster
  cluster_of :email_snapshots
  has_signature :ad

  has_many :account_emails

  def cluster_targeting_id
    # if it's not a cluster of emaisl we sent, it's garbage
    # eg "Welcome to Gmail" email
    (self.snapshots.first.exp_e_id || self.snapshots.first.outsider) ? self.id.to_s : "garbage"
    # self.snapshots.first.outsider ? self.id.to_s : "garbage"
  end

  def subjects
    snapshots.map { |email| email.subject }.uniq
  end

  field :footprint # Hash[Ad => occurence]
  field :normalized_footprint
  field :log_footprint

  field :matched
  field :match_group
  index({ match_group: 1 })

  def footprint
    return super if super
    footprint!
  end

  def footprint!
    self.footprint = Hash.new(0)
    Ad.each do |ad|
      self.footprint[ad.id.to_s] = Snapshot.where( snapshot_cluster: ad, context_cluster: self ).count
    end
  ensure
    self.save
  end

  def self.recompute_footprints
    self.no_timeout.each(&:footprint!)
  end

  def normalized_footprint
    return super if super
    normalized_footprint!
  end

  def normalized_footprint!
    self.normalized_footprint = Hash.new(0)
    Ad.each do |ad|
      ne = Snapshot.where( snapshot_cluster: ad, context_cluster: self ).count
      ntot = ad.snapshots.count
      self.normalized_footprint[ad.id.to_s] = ne.to_f / ntot
    end
  ensure
    self.save
  end

  def self.recompute_normalized_footprints
    self.no_timeout.each(&:normalized_footprint!)
  end

  def log_footprint
    return super if super
    log_footprint!
  end

  def log_footprint!
    self.log_footprint = Hash.new(0)
    Ad.each do |ad|
      ne = Snapshot.where( snapshot_cluster: ad, context_cluster: self ).count
      self.log_footprint[ad.id.to_s] = Math.log(ne + 1)
    end
  ensure
    self.save
  end

  def self.recompute_log_footprints
    self.no_timeout.each(&:log_footprint!)
  end
end
