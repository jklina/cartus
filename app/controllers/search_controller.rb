class SearchController < ApplicationController
  def index
    @users = User.basic_search(params[:query])
  end
end
