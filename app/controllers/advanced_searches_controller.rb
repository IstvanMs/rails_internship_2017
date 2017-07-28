class AdvancedSearchesController < ApplicationController

  def new
    @advanced_search = AdvancedSearch.new
  end

  def create
    @advanced_search = AdvancedSearch.create!(params[:advanced_search].permit!)
    redirect_to @advanced_search
  end

  def show
    @advanced_search = AdvancedSearch.find(params[:id])
  end

end
