require 'spec_helper'

shared_examples_for "creating a snapshot" do |snapshot_klass|
  it "creates an item with right class" do
    post '/snapshots', :type => snapshot_klass.to_s.underscore.split("_").first.downcase,
      :object => {:foo => :bar},
      :account_id => account.id

    response.status.should == 200
    snapshot_klass.last.account.should == account
    snapshot_klass.last.object.should == {'foo' => 'bar'}
  end

  it "creates items with context" do
    ctx = { :type => snapshot_klass.to_s.underscore.split("_").first.downcase,
            :object => {:foo => :bar},
            :account_id => account.id }
    snapshots = [ { :type => snapshot_klass.to_s.underscore.split("_").first.downcase,
                    :object => {:bar => :foo},
                    :account_id => account.id },
                  { :type => snapshot_klass.to_s.underscore.split("_").first.downcase,
                    :object => {:bar => :foo},
                    :account_id => account.id } ]
    post '/snapshots/context', :context => ctx, :snapshots => snapshots

    response.status.should == 200
    snapshot_klass.count.should == 3
    snapshot_klass.all.select { |s| s.object == {'bar' => 'foo'} }.each do |s|
      s.context.object.should == {'foo' => 'bar'}
    end
  end

  context "with no account" do
    it "responds with error" do
      post '/snapshots', :type => snapshot_klass.to_s,
        :object => {:foo => :bar}
      response.status.should == 406
    end
  end
end

describe "Snapshots API" do
  let(:account) { create(:account) }

  context "creating an ad" do
    it_should_behave_like "creating a snapshot", AdSnapshot
  end

  context "creating an email" do
    it_should_behave_like "creating a snapshot", EmailSnapshot
  end

  context "creating a product" do
    it_should_behave_like "creating a snapshot", ProductSnapshot
  end

  context "creating an recommendation" do
    it_should_behave_like "creating a snapshot", RecommendationSnapshot
  end

  context "with an invalid type" do
    it "responds with error" do
      post '/snapshots', :type => "Account",
        :object => {:foo => :bar},
        :account_id => account.id
      response.status.should == 406
    end
  end

  describe "multitenancy" do
    before do
      Mongoid.with_tenant("foo") { AdSnapshot.delete_all }
      Mongoid.with_tenant("bar") { AdSnapshot.delete_all }
    end

    let(:account) { Mongoid.with_tenant("foo") { create(:account) } }

    it "creates items for right tenant" do
      post '/snapshots', :type => "Ad",
        :object => {:foo => :bar},
        :account_id => account.id,
        :exp => "foo"

      response.status.should == 200
      Mongoid.with_tenant("foo") do
        AdSnapshot.last.account.should == account
        AdSnapshot.last.object.should == {'foo' => 'bar'}
      end
      Mongoid.with_tenant("bar") do
        AdSnapshot.count.should == 0
      end
    end

    context "with the account in other tenant" do
      it "responds with error" do
        post '/snapshots', :type => "Ad",
          :object => {:foo => :bar},
          :account_id => account.id,
          :exp => "bar"
        response.status.should == 406
      end
    end
  end
end

