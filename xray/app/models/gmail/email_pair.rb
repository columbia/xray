class EmailPair < SnapshotClusterPair
  has_items :email

  belongs_to :e1, class_name: 'Email'
  belongs_to :e2, class_name: 'Email'

  field :log_distance
  field :proportion_distance

  index({ e1: 1 })
  index({ e2: 1 })
  index({ e1: 1 , e2: 1 }, { :unique => true })
  index({ log_distance: 1 })
  index({ proportion_distance: 1 })
  index({ e1: 1, log_distance: 1 })

  def self.log_distances
    es = Email.all.select { |e| e.cluster_targeting_id != 'garbage' }
    es.combination(2).each do |pair|
      e1, e2 = pair
      ep_1 = self.where( e1: e1, e2: e2 ).first || self.create( e1: e1, e2: e2 )
      ep_2 = self.where( e1: e2, e2: e1 ).first || self.create( e1: e2, e2: e1 )
      dst = Math.sqrt(e1.log_footprint.map { |key, score| (score - e2.log_footprint[key])**2 }.sum)
      ep_1.log_distance = dst
      ep_2.log_distance = dst
      ep_1.save
      ep_2.save
    end
    es.each do |email|
      #  nil is the origin
      ep_1 = self.where( e1: nil, e2: email ).first || self.create( e1: nil, e2: email )
      ep_2 = self.where( e1: email, e2: nil ).first || self.create( e1: email, e2: nil )
      dst = Math.sqrt(email.log_footprint.map { |key, score| (score - 0)**2 }.sum)
      ep_1.log_distance = dst
      ep_2.log_distance = dst
      ep_1.save
      ep_2.save
    end
  end

  def self.cluster(treshold)
    clusters = []
    g = self.lte( log_distance: treshold ).map do |ep|
      e1, e2 = ep.e1, ep.e2
      e1.matched = false
      e2.matched = false
      e1.save
      e2.save
      [e1, e2]
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
        self.where(e1: curr).lte( log_distance: treshold ).map(&:e2).uniq.each { |e| cluster.push(e) }
      end
      clusters.push(cluster.uniq)
    end
    Email.each { |e| e.match_group = nil; e.save }
    clusters.each_with_index { |cl, i| cl.each { |e| e.match_group = i; e.save } }
  end

  def matching_truth
    s1 = e1.snapshots.first.subject.gsub(/email [0-9] - /, '') rescue ''
    s2 = e2.snapshots.first.subject.gsub(/email [0-9] - /, '') rescue ''
    return s1 == s2
  end
end
