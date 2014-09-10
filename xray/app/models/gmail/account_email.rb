class AccountEmail < AccountSnapshotCluster
  field :footprint # Hash[Ad => occurence]
  field :normalized_footprint
  field :log_footprint

  field :clustered

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
      self.footprint[ad.id.to_s] = Snapshot.where( snapshot_cluster: ad, context_cluster: self.snapshot_cluster, account: self.account ).count
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
      ne = Snapshot.where( snapshot_cluster: ad, context_cluster: self.snapshot_cluster, account: self.account ).count
      ntot = ad.snapshots.where(account: account).count
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
      ne = Snapshot.where( snapshot_cluster: ad, context_cluster: self.snapshot_cluster, account: self.account ).count
      self.log_footprint[ad.id.to_s] = Math.log(ne + 1)
    end
  ensure
    self.save
  end

  def self.recompute_log_footprints
    self.no_timeout.each(&:log_footprint!)
  end
end
