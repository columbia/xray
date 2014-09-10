require 'spec_helper'

describe "Compute targeting scores for an ad" do
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
      case email.exp_e_id
      when 1
        [
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 1),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 2),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 2),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 2),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 2),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 2),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 2),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 3),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 3),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 3),
        ]
      when 2
        [
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 1),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 1),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 1),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 1),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 2),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 3),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 3),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 3),
        ]
      else
        [
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 2),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 3),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 3),
          create(:ad_snapshot, email_sn: email, ad_sn_inner_id: 3),
        ]
      end
    end.flatten
  end

  it "computes the right context targeting score" do
    Ad.do_clustering
    Email.do_clustering
    AdSnapshot.set_context_clusters
    AccountEmail.recompute_footprints

    ad1 = Ad.each.select { |ad| ad.snapshots.first.signatures.first == 1.to_s }.first
    ad2 = Ad.each.select { |ad| ad.snapshots.first.signatures.first == 2.to_s }.first
    ad3 = Ad.each.select { |ad| ad.snapshots.first.signatures.first == 3.to_s }.first

    email1 = Email.each
                  .select { |email| email.snapshots.first.exp_e_id == 1 }
                  .first
    email2 = Email.each
                  .select { |email| email.snapshots.first.exp_e_id == 2 }
                  .first
    email3 = Email.each
                  .select { |email| email.snapshots.first.exp_e_id == 3 }
                  .first

    s1 = ad1.context_scores
    s2 = ad2.context_scores
    s3 = ad3.context_scores
    s1[email2.id.to_s].should == s1.values.max
    s2[email1.id.to_s].should == s2.values.max
    s3[nil].should == s3.values.max
    distr = Ad.compute_parameters(:context)
    distr[:p].should be > distr[:q]
    distr[:p].should be > distr[:r]
    distr[:r].should > distr[:q]
  end

  it "computes the right behavior targeting score" do
    Ad.do_clustering
    Email.do_clustering
    AdSnapshot.set_context_clusters
    AccountEmail.recompute_footprints

    ad1 = Ad.each.select { |ad| ad.snapshots.first.signatures.first == 1.to_s }.first
    ad2 = Ad.each.select { |ad| ad.snapshots.first.signatures.first == 2.to_s }.first
    ad3 = Ad.each.select { |ad| ad.snapshots.first.signatures.first == 3.to_s }.first

    email1 = Email.each
                  .select { |email| email.snapshots.first.exp_e_id == 1 }
                  .first
    email2 = Email.each
                  .select { |email| email.snapshots.first.exp_e_id == 2 }
                  .first
    email3 = Email.each
                  .select { |email| email.snapshots.first.exp_e_id == 3 }
                  .first

    s1 = ad1.behavior_scores
    s2 = ad2.behavior_scores
    s3 = ad3.behavior_scores
    s1[email2.id.to_s].should == s1.values.max
    s2[email1.id.to_s].should == s2.values.max
    s3[nil].should == s3.values.max
    distr = Ad.compute_parameters(:behavior)
    distr[:p].should be > distr[:q]
    distr[:p].should be > distr[:r]
    distr[:r].should > distr[:q]
  end
end
