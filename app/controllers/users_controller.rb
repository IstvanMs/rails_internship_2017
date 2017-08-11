class UsersController < ApplicationController
  before_action :admin_user, :only => [:new, :create, :edit, :update, :index]
  before_action :authenticate_user, :only => [:show, :profile]
  
  def index
    @admin = User.find(session[:user_id])
    @company = Company.find(@admin.company_id)
    @roles = Role.where(:company_id => @company.id)
    @search_par = params[:search]

    if @search_par == nil || @search_par == ''
      @users = User.where(:type => nil,:company_id => @company.id).order(:role,:username)
    else
      @users = User.where('type = ? and username like ? and company_id = ?',nil, '%' + @search_par + '%', @company.id).order(:role,:username)
    end
    @user = User.new
  end

  def profile
    @user = User.find(params[:id])
  end

  def change_email
    @user = User.find(session[:user_id])
    if !params[:new_email].match(/\A.+@.+\.+.+\z/)
      flash[:notice] = "Invalid email!"
      flash[:color] = "invalid"
      redirect_to sessions_profile_path
    else
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
    @company = Company.find(params[:company])
    @roles = Role.where(:company_id => @company.id, :role_name => 'admin')
  end

  def reset
    redirect_to index
  end

  def show
    if @current_user.id == params[:id] || @current_user.role == 'Admin' || @current_user.type == 'Superuser'
     @user = User.find(params[:id])
     @role = Role.find(@user.role_id)
    else
      redirect_to root_path
    end
  end

  def edit
    if @current_user.type == 'Superuser'
      @user = User.find(params[:id])
      @company = Company.find(@user.company_id)
      @roles = Role.where(:company_id => @company.id)
      render 'edit'
    else
      @admin = User.find(session[:user_id])
      @company = Company.find(@admin.company_id)
      @roles = Role.where(:company_id => @company.id)
      @user = User.find(params[:id])
      @users = User.where(:type => nil).order(:role,:username)
      render 'index'
    end
  end

  def update 
    if User.find(session[:user_id]).type == 'Superuser'
      @user = User.find(params[:id])
      par = user_params
      @company = Company.find(par[:company_id])
      role_dash = Role.find(par[:role_id]).dashboard.capitalize
      @roles = Role.where(:company_id => @company.id)

      if @user.update({:username => par[:username], :password => par[:password], :password_confirmation => par[:password_confirmation], :email => par[:email], :role => role_dash, :company_id => par[:company_id], :role_id => par[:role_id]})
        redirect_to company_path(@company)
      else
        render 'edit'
      end
    else
      @admin = User.find(session[:user_id])
      @company = Company.find(@admin.company_id)
      @roles = Role.where(:company_id => @company.id)
      @user = User.find(params[:id])
      @users = User.where(:type => nil,:company_id => @company.id).order(:role,:username)
      par = user_params
      role_dash = Role.find(par[:role_id]).dashboard.capitalize

      if @user.update({:username => par[:username], :password => par[:password], :password_confirmation => par[:password_confirmation], :email => par[:email], :role => role_dash, :company_id => par[:company_id], :role_id => par[:role_id]})
        redirect_to users_path
      else
        render 'index'
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @company = Company.find(@user.company_id)
    @user.destroy

    if User.find(session[:user_id]).type == 'Superuser'
      redirect_to company_path(@company)
    else
      redirect_to users_path
    end
  end

  def create
    if @current_user.type == 'Superuser'
      par = user_params
      role_dash = Role.find(par[:role_id]).dashboard.capitalize
      @company = Company.find(par[:company_id])
      @user = User.new({:username => par[:username], :password => par[:password], :password_confirmation => par[:password_confirmation], :email => par[:email], :role => role_dash, :company_id => par[:company_id], :role_id => par[:role_id]})
    
      if @user.save 
        MailerMailer.new_user(@user).deliver
        flash[:notice] = "Saved!"
        flash[:color] = "valid"
        redirect_to company_path(@company)
      else
        flash[:notice] = "Invalid form!"
        flash[:color] = "invalid"
        render 
      end
    else
      @admin = User.find(session[:user_id])
      @company = Company.find(@admin.company_id)
      @roles = Role.where(:company_id => @company.id)
      par = user_params
      role_dash = Role.find(par[:role_id]).dashboard.capitalize
      @user = User.new({:username => par[:username], :password => par[:password], :password_confirmation => par[:password_confirmation], :email => par[:email], :role => role_dash, :company_id => par[:company_id], :role_id => par[:role_id]})
      @users = User.where(:type => nil,:company_id => @company.id).order(:role,:username)

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
  end

  private 
    def user_params
      params.require(:user).permit(:username, :password, :password_confirmation, :email, :company_id, :role_id)
    end
end