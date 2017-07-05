class SessionsController < ApplicationController
  before_action :authenticate_user, :only => [:home, :profile, :setting]
  before_action :save_login_state, :only => [:login, :login_attempt]

  def login
  end

  def home
  end

  def profile
  end

  def setting
  end

  def logout
  	session[:user_id] = nil
    flash[:notice] = ""
  	redirect_to :action => 'login'
  end

  def login_attempt
  	authorized_user = User.authenticate(params[:username],params[:login_password])

  	if authorized_user
  		session[:user_id] = authorized_user.id
  		redirect_to(:action => 'home')
  	else
  		flash[:notice] = "Invalid username or password!"
  		flash[:color] = "invalid"
  		render 'login'
  	end
  end
end
