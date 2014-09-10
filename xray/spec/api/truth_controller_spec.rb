require 'spec_helper'

shared_examples_for "creating a truth" do |truth_klass|
  it "creates an item with right class" do
    obj = { "exp_email_id" => 1,
            "exp_email"    => {'foo'  => 'bar'},
            "ad_id"        => ad.id }
    post '/truth', obj

    response.status.should == 200
    truth_klass.last.exp_email.should == {'foo' => 'bar'}
    truth_klass.last.ad.should == ad
  end
end

describe "Truth API" do
  let(:ad) { create(:ad) }

  context "creating a gmail truth" do
    it_should_behave_like "creating a truth", GmailTruth
  end
end
