class AdvancedSearchesController < ApplicationController
  before_action :authenticate_user

  def new
    @advanced_search = AdvancedSearch.new
  end

  def create
    @advanced_search = AdvancedSearch.create!(params[:advanced_search].permit!)
    redirect_to "/tasks/index/#{@advanced_search.id}"

  end

  def show
    @advanced_search = AdvancedSearch.find(params[:id])
  end

end
