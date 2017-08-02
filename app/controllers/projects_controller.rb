class ProjectsController < ApplicationController
	before_action :manager_user, :only => [:new, :edit, :create, :update, :destroy]
	before_action :authenticate_user, :only => [:index, :show]
	
	def index
		@search_par = params[:search]
		if @current_user.role == 'Manager'
			if @search_par == nil || @search_par == ''
				@projects = Project.all.order(:title)
			else
				@projects = Project.where('title like ?', '%' + @search_par + '%').order(:title)
			end
		else
			if @search_par == nil || @search_par == ''
				@projects = @current_user.projects.order(:title)
			else
				@projects = Project.where('id in(?) and title like ?', @current_user.projects.ids, '%' + @search_par + '%').order(:title)
			end
		end
		@lengths = {'projects' => @projects.length}
		@projects = @projects.paginate(:page => params[:page], :per_page => 50)
		@project_infos = Project.create_project_infos(@projects)
	end	

	def add_user
		@project = Project.find(params[:id])
		@user = User.find(params[:selected_id])
		@project_user = ProjectUser.new do |u|
			u.user = @user
			u.project = @project
		end
		if @project_user.save
			flash[:notice] = "Saved!"
      		flash[:color] = "valid"
      		MailerMailer.assigned_to_project(@user, @project).deliver
			redirect_to project_path(@project)
		else
			flash[:notice] = "Error on save!"
      		flash[:color] = "invalid"
			redirect_to project_path(@project)
		end
	end

	def remove_user
		@project = Project.find(params[:project_id])
		@user = User.find(params[:user_id])
		@project_user = ProjectUser.find_by('user_id = ? and project_id = ? ', @user.id, @project.id)
		if @project_user.destroy
			flash[:notice] = "Removed from project!"
      		flash[:color] = "valid"
			redirect_to project_path(@project)
		else
			flash[:notice] = "Error on delete!"
      		flash[:color] = "invalid"
			redirect_to project_path(@project)
		end
	end

	def search
		redirect_to projects_index_path(:search => params[:search])
	end

	def show
		@users_in = ProjectUser.where(:project_id => params[:id]).collect(&:user)
		@table = ProjectUser.where(:project_id => params[:id]).collect(&:user_id)
		if @table.length > 0
			@users_sel = User.where('id NOT IN (?)', @table)
		else
			@users_sel = User.all
		end
		@clients = User.where(:role => 'Client')
		@project = Project.find(params[:id])
		@users = User.where.not(:role => 'Client')
		client_name = User.joins(:projects).where(:role => 'Client', :projects => {:id => params[:id]}).first
		if client_name != nil
			@project_infos = {'client_name' => client_name.username,'created_at' => @project.created_at.strftime("%F %I:%M%p")  }
		else 
			@project_infos = {'client_name' => '-','created_at' => @project.created_at.strftime("%F %I:%M%p")  }
		end
	end	

	def new
		@clients = User.where(:role => 'Client')
		@project = Project.new
	end

	def edit
		@clients = User.where(:role => 'Client')
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
				@project.destroy
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
