require 'spec_helper'

describe AccountsController do
  it "creates an account" do
    post '/accounts'

    response.status.should == 200
    JSON.parse(response.body)['id'].should == Account.last._id.to_s
  end
end
