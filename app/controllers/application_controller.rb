class ApplicationController < ActionController::Base
  wrap_parameters false

  around_filter :with_database

  def with_database
    if params[:exp]
      Mongoid.with_tenant(params[:exp]) { yield }
    else
      yield
    end
  end
end
