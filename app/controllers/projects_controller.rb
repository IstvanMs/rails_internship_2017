class ProjectsController < ApplicationController
	before_action :manager_user, :only => [:new, :edit, :create, :update, :destroy]
	before_action :authenticate_user, :only => [:index, :show]
	
	def index
		case @current_user.role
		when 'Manager'
			@projects = Project.all.order(:title).first(6)
		when 'Employee'
			@projects = Project.where(:id => Task.where(:assigned_user => @current_user.id).collect{|t| t.project.id}).order(:title).first(6)
		when 'Admin'
			@projects = Project.where(:id => Task.where(:assigned_user => @current_user.id).collect{|t| t.project.id}).order(:title).first(6)
		when 'Client'
			@projects = Project.where(:id => ProjectUser.where(:user => User.find(@current_user.id)).collect{|p| p.project.id}).order(:title).first(6)
		else
			puts 'Role error!'
		end
	end	

	def show
		@project = Project.find(params[:id])
		@users = User.where.not(:role => 'Client')
	end	

	def new
		@clients = User.where(:role => 'Client')
		@project = Project.new
	end

	def edit
		@project = Project.find(params[:id])
		@users = User.where.not(:role => 'Client')
	end

	def create
		@clients = User.where(:role => 'Client')
		@project = Project.new(project_params)
 
		if @project.save
			@project_user = ProjectUser.new do |u|
			  u.user = User.find(params[:client])
			  u.project = @project
			end

			if @project_user.save
				redirect_to projects_path
			else
				puts 'error'
			end
		else
			render 'new'
		end
	end

	def update
		@project = Project.find(params[:id]) 
		@users = User.where.not(:role => 'Client')

		if @project.update(project_params)
			redirect_to @project
		else
			render 'edit'
		end
	end

	def destroy
		@project = Project.find(params[:id])
		@project.destroy
		@users = User.where.not(:role => 'Client')
 
		redirect_to projects_path
	end

	private
	def project_params
		params.require(:project).permit(:title, :text)
	end

end
