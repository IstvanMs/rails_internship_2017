class UsersController < ApplicationController
  before_action :save_login_state, :only => [:new, :create]

  def index
  	@users = User.all
  end

  def new
  	@user = User.new
  end

  def show
  	@user = User.find(params[:id])
  end

  def edit
  	@user = User.find(params[:id])
  end

  def update 
  	@user = User.find(params[:id])

  	if @user.update(user_params)
  		#redirect
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

  	if @user.save 
  		flash[:notice] = "You signed up succesfully!"
  		flash[:color] = "valid"
  		#redirect to mainpage
  	else
  		flash[:notice] = "Invalid form!"
  		flash[:color] = "invalid"
  		render "new"
  	end
  end

  private 
  	def user_params
  		params.require(:user).permit(:username, :password, :password_confirmation, :role)
  	end
end
