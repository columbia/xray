class AccountEmailPair
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :ae1, class_name: 'AccountEmail'
  belongs_to :ae2, class_name: 'AccountEmail'

  field :log_distance
  field :proportion_distance

  index({ ae1: 1 })
  index({ ae2: 1 })
  index({ ae1: 1 , ae2: 1 }, { :unique => true })
  index({ log_distance: 1 })
  index({ proportion_distance: 1 })
  index({ ae1: 1, log_distance: 1 })

  def self.log_distances
    aes = AccountEmail.all.select { |e| e.snapshot_cluster.cluster_targeting_id != 'garbage' }
    aes.combination(2).each do |pair|
      ae1, ae2 = pair
      aep_1 = self.where( ae1: ae1, ae2: ae2 ).first || self.create( ae1: ae1, ae2: ae2 )
      aep_2 = self.where( ae1: ae2, ae2: ae1 ).first || self.create( ae1: ae2, ae2: ae1 )
      dst = Math.sqrt(ae1.log_footprint.map { |key, score| (score - ae2.log_footprint[key])**2 }.sum)
      aep_1.log_distance = dst
      aep_2.log_distance = dst
      aep_1.save
      aep_2.save
    end
    aes.each do |ae|
      #  nil is the origin
      aep_1 = self.where( ae1: nil, ae2: ae ).first || self.create( ae1: nil, ae2: ae )
      aep_2 = self.where( ae1: ae, ae2: nil ).first || self.create( ae1: ae, ae2: nil )
      dst = Math.sqrt(ae.log_footprint.map { |key, score| (score - 0)**2 }.sum)
      aep_1.log_distance = dst
      aep_2.log_distance = dst
      aep_1.save
      aep_2.save
    end
  end

  def self.cluster(treshold)
    clusters = []
    g = self.lte( log_distance: treshold ).map do |aep|
      ae1, ae2 = aep.ae1, aep.ae2
      ae1.matched = false
      ae2.matched = false
      ae1.save
      ae2.save
      [ae1, ae2]
    end
    g.flatten.uniq.each do |cand|  # just a basic BFS
      cand.reload
      next if cand.matched  # we already processed it
      cluster = [cand]
      current = 0
      while current < cluster.size do
        curr = cluster[current]
        curr.reload
        current += 1
        next if curr.matched
        curr.matched = true
        curr.save
        self.where(ae1: curr).lte( log_distance: treshold ).map(&:ae2).uniq.each { |e| cluster.push(e) }
      end
      clusters.push(cluster.uniq)
    end
    AccountEmail.each { |ae| ae.match_group = nil; ae.save }
    clusters.each_with_index { |cl, i| cl.each { |ae| ae.match_group = i; ae.save } }
  end

  def matching_truth
    s1 = ae1.snapshot_cluster.snapshots.first.subject.gsub(/email [0-9] - /, '') rescue ''
    s2 = ae2.snapshot_cluster.snapshots.first.subject.gsub(/email [0-9] - /, '') rescue ''
    return s1 == s2
  end
end
