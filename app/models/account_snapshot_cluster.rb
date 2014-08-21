class AccountSnapshotCluster
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :account
  belongs_to :snapshot_cluster

  index({ account: 1 })
  index({ snapshot_cluster: 1 })
  index({ account: 1, snapshot_cluster: 1 }, { :unique => true })

  # creates and alias for the cluster name
  def self.inherited(c)
    super
    c.send(:define_method, c.name.underscore.split("_")[1..-1].join("_")) do
      self.snapshot_cluster
    end
  end
end
