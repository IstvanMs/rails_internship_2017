class RolesController < ApplicationController
	before_action :admin_user, :only => [:create, :edit, :update, :index]

	def edit
		@admin = User.find(session[:user_id])

		@role = Role.find(params[:id])
		@company = Company.find(@admin.company_id)
		@roles = Role.where(:company_id => @company).order(:dashboard)

		if @role.role_name == 'admin'
        	flash[:notice] = "Modify denied!"
        	flash[:color] = "invalid"
        	@role = Role.new
		end
		render 'index'
	end

	def update
		@role = Role.find(params[:id])

		if @role.update(role_params)
			flash[:notice] = "Role updated!"
        	flash[:color] = "valid"
        else
        	flash[:notice] = "Error in update!"
        	flash[:color] = "invalid"
        end

        redirect_to roles_path
	end

	def destroy
		@role = Role.find(params[:id])
		if @role.role_name != 'admin'
			flash[:notice] = "Role destroyed!"
        	flash[:color] = "valid"
			@role.destroy
		else
			flash[:notice] = "Can't destroy the admin role!"
        	flash[:color] = "invalid"
        end

		redirect_to roles_path
	end

	def create
		@role = Role.new(role_params)

		if @role.save 
			flash[:notice] = "Role saved!"
        	flash[:color] = "valid"
        else
        	flash[:notice] = "Error in save!"
        	flash[:color] = "invalid"
        end

        redirect_to roles_path
  	end

	def index
		@admin = User.find(session[:user_id])
		@role = Role.new

		@company = Company.find(@admin.company_id)
		@roles = Role.where(:company_id => @company).order(:dashboard)
	end

	private 
	  	def role_params
	  		params.require(:role).permit(:role_name, :dashboard, :company_id)
	  	end
end