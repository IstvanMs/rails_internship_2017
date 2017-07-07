class ProjectsController < ApplicationController
	before_action :manager_user, :only => [:index, :show, :new, :edit, :create, :update, :destroy]
	
	def index
		@projects = Project.all
	end	

	def show
		@project = Project.find(params[:id])
		@users = User.where.not(:role => 'Client')
	end	

	def new
		@project = Project.new
	end

	def edit
		@project = Project.find(params[:id])
		@users = User.where.not(:role => 'Client')
	end

	def create
		@project = Project.new(project_params)
 
		if @project.save
			redirect_to @project
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
