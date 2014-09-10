require 'spec_helper'

describe "Experiment flow" do
  before do
    # use test configs instead of default
    Experiment.fixed_db :exp_test
    Experiment.accounts_from :test_pool
    # clean the database
    Mongoid.with_tenant("exp_test") { Experiment.delete_all }
    Mongoid.with_tenant("test_pool") { Account.delete_all }
    Mongoid.with_tenant("foobar") do
      Experiment.delete_all
      Account.delete_all
      EmailSnapshot.delete_all
      AdSnapshot.delete_all
    end
  end

  let!(:experiment) do
    emails = [
      [{ 'subject' => "my thread 1",
         :html    => "<b>Hello</b>,", },
       { 'subject' => "my thread 1",
         :text    => "world!", }, ],

      [{ 'subject' => "my t 2",
         :html    => "Hello,", },
       { 'subject' => "my t 2",
         :text    => "<b>world!</b>", }, ],
    ]
    Experiment.create({ :name           => "foobar",
                        :type           => "gmail",
                        :account_number => 3,
                        :e_perc_a       => 0.5,
                        :emails         => emails, })
  end

  let!(:accounts) do
    Mongoid.with_tenant("test_pool") do
      [
      ]
    end
  end

  it "takes accounts in the pool" do
    experiment.get_accounts

    Mongoid.with_tenant("test_pool") do
      GoogleAccount.available_accounts.count
    end.should == 1

    Mongoid.with_tenant("foobar") do
      GoogleAccount.count
    end.should == 3
  end

  it "assigns emails" do
    experiment.get_accounts

    experiment.assign_emails

    experiment.e_a_assignments.size.should == 2
    experiment.e_a_assignments.values.each { |v| v.size.should == 1 }
    experiment.master_emails.should =~ experiment.emails
    experiment.e_a_assignments[experiment.master_account].should == nil
    Mongoid.with_tenant("foobar") do
      GoogleAccount.where('_id' => experiment.master_account).count
    end.should == 1
  end

  it "sends emails" do
    # uncomment only to test email sending
    # too long otherwise

    # experiment.get_accounts
    # experiment.assign_emails

    # experiment.send_emails
  end

  it "does a measurement" do
    # uncomment only to test email sending
    # too long otherwise

    # experiment.get_accounts
    # experiment.assign_emails

    # experiment.start_measurement 1
    # Mongoid.with_tenant("foobar") { AdSnapshot.count }.should be > 0
    # Mongoid.with_tenant("foobar") { EmailSnapshot.count }.should be > 0
  end
end
