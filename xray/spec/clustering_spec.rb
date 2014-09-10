require 'spec_helper'

shared_examples_for "a cluster" do |cluster_klass, item_klass|
  describe "Clustering" do
    let(:account) { create(:account) }
    let(:account2) { create(:account) }
    let(:relation_klass) { "Account#{cluster_klass.name}".constantize }

    it "works with some weird cases" do
      item1 = item_klass.create(:signatures => ["1", "2"],
                                :account_id => account.id)
      item_klass.create(:signatures => ["2", "3"],
                        :account_id => account.id)
      item_klass.create(:signatures => ["3", "4"],
                        :account_id => account.id)
      item_klass.create(:signatures => ["4", "5"],
                        :account_id => account.id)
      item2 = item_klass.create(:signatures => ["6", "7", "8"],
                                :account_id => account.id)
      cluster_klass.do_clustering

      cluster_klass.count.should == 2
      item1.reload
      item2.reload
      item1.snapshot_cluster.snapshots.count.should == 4
      item2.snapshot_cluster.snapshots.count.should == 1
      relation_klass.count.should == 2
      relation_klass.first.account.should == account
      relation_klass.all.map(&:snapshot_cluster).should =~ cluster_klass.all.to_a

      # reclustering still gives the right results
      cluster_klass.do_clustering

      cluster_klass.count.should == 2
      item1.reload
      item2.reload
      item1.snapshot_cluster.snapshots.count.should == 4
      item2.snapshot_cluster.snapshots.count.should == 1
      relation_klass.count.should == 2
      relation_klass.first.account.should == account
      relation_klass.all.map(&:snapshot_cluster).should =~ cluster_klass.all.to_a

      # reclustering with a linking element merges the clusters
      item3 = item_klass.create(:signatures => ["3", "4", "7"],
                                :account_id => account.id)
      cluster_klass.do_clustering

      cluster_klass.count.should == 1
      item1.reload
      item2.reload
      item3.reload
      item1.snapshot_cluster.snapshots.count.should == 6
      relation_klass.count.should == 1
      relation_klass.all.map(&:snapshot_cluster).should =~ cluster_klass.all.to_a

      # adding an item with a new accounts creates
      # the account_cluster relationship
      item_klass.create(:signatures => ["3", "4", "7"],
                        :account_id => account2.id)
      cluster_klass.do_clustering
      relation_klass.count.should == 2
      relation_klass.all.map(&:account).should =~ Account.all.to_a
      relation_klass.all.map(&:snapshot_cluster).uniq.should =~ cluster_klass.all.to_a
      relation_klass.all.map(&:snapshot_cluster).count.should == cluster_klass.count * Account.count
    end
  end
end

describe "Parent Clustering" do
  it_should_behave_like "a cluster", SnapshotCluster, Snapshot
end

describe "Ad Clustering" do
  it_should_behave_like "a cluster", Ad, AdSnapshot
end

describe "Email Clustering" do
  it_should_behave_like "a cluster", Email, EmailSnapshot
end

describe "Recommendation Clustering" do
  it_should_behave_like "a cluster", Recommendation, RecommendationSnapshot
end

describe "Product Clustering" do
  it_should_behave_like "a cluster", Product, ProductSnapshot
end
