class SessionsController < ApplicationController
  before_action :authenticate_user, :only => [:home, :profile, :setting, :logout]
  before_action :save_login_state, :only => [:login, :login_attempt]

  def forgot_password
  end

  def reset
    email = params[:email]
    if email == nil
      flash[:notice] = "Empty email field!"
      flash[:color] = "invalid"
      redirect_to(:action => 'forgot_password')
    else
      if !User.exists?(:email => email)
        flash[:notice] = "Wrong email!"
        flash[:color] = "invalid"
        redirect_to(:action => 'forgot_password')
      else
        @user = User.find_by(:email => email)
        password = rand(36**8).to_s(36)
        @user.password = password
        @user.encrypt_password
        if @user.save
          flash[:notice] = "Password reseted!"
          flash[:color] = "valid"
          #send email with the new password
          redirect_to(:action => 'login')
        else
          flash[:notice] = "Error in update!"
          flash[:color] = "invalid"
          redirect_to(:action => 'forgot_password')
        end 
      end
    end
  end

  def login
  end

  def home
    redirect_to dashboards_index_path
  end

  def profile
    @user = User.find(@current_user.id)
     @role = Role.find(@user.role_id)
    render 'users/show'
  end

  def setting
  end

  def logout
  	session[:user_id] = nil
    session[:reports_year] = nil
    session[:reports_month] = nil
    session[:reports_user] = nil
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