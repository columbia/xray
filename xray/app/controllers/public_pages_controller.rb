class PublicPagesController < ApplicationController
  def home
    if user_signed_in?
      @text = current_user.email
    else
      @text = "not logged in"
    end
  end

  def contact
  end

  def about
  end

  def help
  end
end
