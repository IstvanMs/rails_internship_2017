class UsersController < ApplicationController
  before_action :admin_user, :only => [:new, :create, :edit, :update, :index]
  before_action :authenticate_user, :only => [:show]
  
  def index
    @search_par = params[:search]

    if @search_par == nil || @search_par == ''
  	  @users = User.all.order(:role,:username)
    else
      @users = User.where('username like ?', '%' + @search_par + '%').order(:role,:username)
    end
    @user = User.new
  end

  def change_email
    @user = User.find(session[:user_id])
    @old = @user.email
    if @user.update_attribute(:email, params[:new_email]) 
      flash[:notice] = "Email saved!"
      flash[:color] = "valid"
      @current_user = User.find(@user.id)
      MailerMailer.change_email(@current_user.email, @current_user, @old).deliver
      MailerMailer.change_email(@old, @current_user, @old).deliver
      redirect_to sessions_profile_path
    else
      flash[:notice] = "Invalid email!"
      flash[:color] = "invalid"
      redirect_to sessions_profile_path
    end
  end

  def change_password
    @user = User.find(session[:user_id])
    if params[:pass1] != params[:pass2]
      flash[:notice] = "Different passwords!"
      flash[:color] = "invalid"
      redirect_to sessions_profile_path
    else
      @user.password = params[:pass1]
      @user.encrypt_password
      if @user.save
        flash[:notice] = "Password saved!"
        flash[:color] = "valid"
        @current_user = User.find(@user.id)
        MailerMailer.reset_password(@current_user, params[:pass1]).deliver
        redirect_to sessions_profile_path
      else
        flash[:notice] = "Invalid password!"
        flash[:color] = "invalid"
        redirect_to sessions_profile_path
      end
    end
  end

  def search
    redirect_to users_index_path(:search => params[:search])
  end

  def new
  	@user = User.new
  end

  def reset
    redirect_to index
  end

  def show
  	@user = User.find(params[:id])
  end

  def edit
  	@user = User.find(params[:id])
    @users = User.all.order(:role,:username)
    render 'index'
  end

  def update 
  	@user = User.find(params[:id])

  	if @user.update(user_params)
  	  redirect_to users_path
  	else
  		render 'edit'
  	end
  end

  def destroy
  	@user = User.find(params[:id])
  	@user.destroy

  	redirect_to users_path
  end

  def create
  	@user = User.new(user_params)
    @users = User.all.order(:role,:username)

  	if @user.save 
      MailerMailer.new_user(@user).deliver
  		flash[:notice] = "Saved!"
  		flash[:color] = "valid"
  		redirect_to users_path
  	else
  		flash[:notice] = "Invalid form!"
  		flash[:color] = "invalid"
  		render "index"
  	end
  end

  private 
  	def user_params
  		params.require(:user).permit(:username, :password, :password_confirmation, :email, :role)
  	end
end
