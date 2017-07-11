class SessionsController < ApplicationController
  before_action :authenticate_user, :only => [:home, :profile, :setting, :logout]
  before_action :save_login_state, :only => [:login, :login_attempt]

  def login
  end

  def home
    redirect_to dashboards_index_path
  end

  def profile
    @user = User.find(@current_user.id)
    render 'users/show'
  end

  def setting
  end

  def logout
  	session[:user_id] = nil
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
