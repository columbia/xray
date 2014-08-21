class Snapshot
  include Mongoid::Document
  include Mongoid::Timestamps

  paginates_per 20

  field :object
  field :iteration
  field :signatures  # for test purposes

  field :ported, :default => false

  belongs_to :account
  belongs_to :snapshot_cluster
  belongs_to :context, class_name: 'Snapshot'
  belongs_to :context_cluster, class_name: 'SnapshotCluster'

  index({ account: 1 })
  index({ snapshot_cluster: 1 })
  index({ context: 1 })
  index({ context_cluster: 1 })
  index({ snapshot_cluster: 1 , context_cluster: 1 })
  index({ account: 1 , snapshot_cluster: 1 })
  index({ account: 1 , context_cluster: 1 })
  index({ account: 1 , snapshot_cluster: 1, context_cluster: 1 })

  class_attribute :context_klass
  def self.has_context(klass)
    self.context_klass = klass.to_s.classify.constantize
  end

  # creates and alias for the cluster name
  # in all snapshot subclass
  def self.inherited(c)
    super
    c.send(:define_method, c.name.tableize.split("_").first) do
      self.snapshot_cluster
    end
  end

  validates :account, :presence => true

  def self.set_context_clusters
    self.no_timeout.each do |sn|
      sn.context_cluster = nil
      sn.context_cluster = sn.context.snapshot_cluster if sn.context
      sn.save!
    end
  end
end
