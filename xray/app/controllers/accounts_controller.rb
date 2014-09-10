class AccountsController < ApplicationController
  def create
    if params['login'] && Account.where( login: params['login'] ).count > 0
      render :status => :ok
      return
    end
    puts Account.count
    acc = Account.create!(params)
    render :status => :ok, :json => { id: acc._id.to_s }
  end
end
