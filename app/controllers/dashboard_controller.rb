class WelcomeController < ApplicationController

  def index
  	render "index_#{@current_user[:role]}"
  	@notes=Notes.all
  end
  
end
