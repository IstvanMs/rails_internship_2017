class UsersController < ApplicationController
  before_action :authenticate_user
  
  def index
    role = Role.find(@current_user.role_id)
    if role.permissions[3].to_f % 2 == 0
      redirect_to root_path
    end
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
    role = Role.find(@current_user.role_id)
    if role.permissions[3] == '0'
      redirect_to root_path
    end
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
    role = Role.find(@current_user.role_id)
    if role.permissions[3] == '0'
      redirect_to root_path
    end
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
    role = Role.find(@current_user.role_id)
    if role.permissions[3] == '0'
      redirect_to root_path
    end
    role = Role.find(@current_user.role_id)
    if role.permissions[3] == '0'
      redirect_to root_path
    end
    redirect_to users_index_path(:search => params[:search])
  end

  def new
    if @current_user.type != 'Superuser'
      role = Role.find(@current_user.role_id)
      if role.permissions[3].to_f % 2 == 0
        redirect_to root_path
      end
    end
    @user = User.new
    @company = Company.find(params[:company])
    @roles = Role.where(:company_id => @company.id, :role_name => 'admin')
  end

  def get_user_fields
    role = Role.find(@current_user.role_id)
    if role.permissions[3].to_f % 2 != 0
      role_fields = RoleField.where(:role_id => params[:role_id])
      field_values = UserField.where(:user_id => params[:user_id])

      respond_to do |format|
        format.json { render json:  {'role_fields': role_fields, 'field_values': field_values}}
      end
    else
      respond_to do |format|
        format.json { render json:  {'nope': '_@_/"'}}
      end
    end
  end

  def reset
    redirect_to index
  end

  def show
    if @current_user.id == params[:id] || @current_user.role == 'Admin' || @current_user.type == 'Superuser'
     @user = User.find(params[:id])
     @role = Role.find(@user.role_id)
     @user_fields = UserField.where(:user_id => @user.id)
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
      role = Role.find(@current_user.role_id)
      if role.permissions[3].to_f % 2 == 0
        redirect_to root_path
      end
      @admin = User.find(session[:user_id])
      @company = Company.find(@admin.company_id)
      @roles = Role.where(:company_id => @company.id)
      @user = User.find(params[:id])
      @users = User.where(:type => nil, :company_id => @company.id).order(:role,:username)
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
      role = Role.find(@current_user.role_id)
      if role.permissions[3].to_f % 2 == 0
        redirect_to root_path
      end
      @admin = User.find(session[:user_id])
      @company = Company.find(@admin.company_id)
      @roles = Role.where(:company_id => @company.id)
      @user = User.find(params[:id])
      @users = User.where(:type => nil,:company_id => @company.id).order(:role,:username)
      par = user_params
      role_dash = Role.find(par[:role_id]).dashboard.capitalize
      if @user.role_id != par[:role_id]
        user_fields = UserField.where(:user_id => @user.id)
        user_fields.each do |uf|
          uf.destroy 
        end
      end

      role_fields = RoleField.where(:role_id => @user.role_id)
      @values = Hash.new
      role_fields.each do |rf|
        @values[rf.name.capitalize] = params[:user][rf.name.capitalize]
      end
      @values = @values.to_json


      if @user.update({:username => par[:username], :password => par[:password], :password_confirmation => par[:password_confirmation], :email => par[:email], :role => role_dash, :company_id => par[:company_id], :role_id => par[:role_id]})
        role_fields.each do |rf|
          if UserField.exists?(:user_id => @user.id, :name => rf.name.capitalize)
            user_field = UserField.find_by(:user_id => @user.id, :name => rf.name.capitalize)
            user_field.update_attribute(:value, params[:user][rf.name.capitalize])
          else
            user_field = UserField.create({:user_id => @user.id, :name => rf.name.capitalize, :value => params[:user][rf.name.capitalize]})
            user_field.save
          end
        end

        redirect_to users_path
      else
        render 'index'
      end
    end
  end

  def destroy
    if User.find(session[:user_id]).type == 'Superuser'
      @user = User.find(params[:id])
      @company = Company.find(@user.company_id)
      @user.destroy
      redirect_to company_path(@company)
    else
      role = Role.find(@current_user.role_id)
      if role.permissions[3].to_f % 2 == 0
        redirect_to root_path
      end
      @user = User.find(params[:id])
      @company = Company.find(@user.company_id)
      @user.destroy
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
      role = Role.find(@current_user.role_id)
      if role.permissions[3].to_f % 2 == 0
        redirect_to root_path
      end
      @admin = User.find(session[:user_id])
      @company = Company.find(@admin.company_id)
      @roles = Role.where(:company_id => @company.id)
      par = user_params
      role_dash = Role.find(par[:role_id]).dashboard.capitalize
      @user = User.new({:username => par[:username], :password => par[:password], :password_confirmation => par[:password_confirmation], :email => par[:email], :role => role_dash, :company_id => par[:company_id], :role_id => par[:role_id]})
      @users = User.where(:type => nil,:company_id => @company.id).order(:role,:username)
      
      role_fields = RoleField.where(:role_id => @user.role_id)
      @values = Hash.new
      role_fields.each do |rf|
        @values[rf.name.capitalize] = params[:user][rf.name.capitalize]
      end
      @values = @values.to_json

      if @user.save 
        MailerMailer.new_user(@user).deliver
        flash[:notice] = "Saved!"
        flash[:color] = "valid"

        role_fields.each do |rf|
          if UserField.exists?(:user_id => @user.id, :name => rf.name.capitalize)
            user_field = UserField.find_by(:user_id => @user.id, :name => rf.name.capitalize)
            user_field.update_attribute(:value, params[:user][rf.name.capitalize])
          else
            user_field = UserField.create({:user_id => @user.id, :name => rf.name.capitalize, :value => params[:user][rf.name.capitalize]})
            user_field.save
          end
        end

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