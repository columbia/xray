require 'spec_helper'

describe "Compute email footprints for a group" do
  let!(:accounts)      { create_list(:account, 3) }

  let!(:email_snapshots) do
    [
      create(:email_snapshot, account: accounts[0], email_snapshot_id: 1),
      create(:email_snapshot, account: accounts[1], email_snapshot_id: 1),

      create(:email_snapshot, account: accounts[1], email_snapshot_id: 2),
      create(:email_snapshot, account: accounts[2], email_snapshot_id: 2),

      create(:email_snapshot, account: accounts[2], email_snapshot_id: 3),
      create(:email_snapshot, account: accounts[0], email_snapshot_id: 3),
    ]
  end

  let!(:ads) do
    email_snapshots.map do |email|
      [
        create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 1),
        create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 2),
        create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 2),
      ]
    end.flatten
  end

  it "computes the right footprints" do
    Ad.do_clustering
    Email.do_clustering
    AdSnapshot.set_context_clusters
    AccountEmail.recompute_footprints

    ad1 = Ad.each.select { |ad| ad.snapshots.first.signatures.first == 1.to_s }.first
    ad2 = Ad.each.select { |ad| ad.snapshots.first.signatures.first == 2.to_s }.first
    AccountEmail.each_with_index do |acc_e, i|
      acc_e.footprint[ad1.id.to_s].should == 1
      acc_e.footprint[ad2.id.to_s].should == 2
    end
  end

  # it "computes the right contextual footprint" do
    # Ad.do_clustering
    # Email.do_clustering
    # AccountEmail.compute_all_footprints
    # AccountEmail.prepare_match_emails
    # AccountEmail.

    # ad1 = Ad.each.select { |ad| ad.snapshots.first.signatures.first == 1.to_s }.first
    # ad2 = Ad.each.select { |ad| ad.snapshots.first.signatures.first == 2.to_s }.first
    # AccountEmail.each_with_index do |acc_e, i|
      # acc_e.footprint[ad1.id.to_s].should == 1
      # acc_e.footprint[ad2.id.to_s].should == 2
    # end
  # end
end
