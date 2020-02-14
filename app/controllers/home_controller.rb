class HomeController < ApplicationController
  def index
    if signed_in?
      redirect_to user_path(current_user)
    else
      redirect_to sign_in_path
    end
  end
end
