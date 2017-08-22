class ProjectsController < ApplicationController
	before_action :manager_user, :only => [:new, :edit, :create, :update, :destroy]
	before_action :authenticate_user
	
	def index
	    role = Role.find(@current_user.role_id)
	    if role.permissions[0] == '0'
	      redirect_to root_path
	    end
		@company = Company.find(@current_user.company_id)
		@search_par = params[:search]
		if @current_user.role == 'Manager'
			if @search_par == nil || @search_par == ''
				@projects = Project.where(:company_id => @company.id).order(:title)
			else
				@projects = Project.where('company_id = ? and title like ?', @company.id, '%' + @search_par + '%').order(:title)
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
	    role = Role.find(@current_user.role_id)
	    if role.permissions[0].to_f % 2 == 0
	      redirect_to root_path
	    end
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
	    role = Role.find(@current_user.role_id)
	    if role.permissions[0].to_f % 2 == 0
	      redirect_to root_path
	    end
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
	    role = Role.find(@current_user.role_id)
	    if role.permissions[0] == '0'
	      redirect_to root_path
	    end
		redirect_to projects_index_path(:search => params[:search])
	end

	def show
	    role = Role.find(@current_user.role_id)
	    if role.permissions[0] == '0'
	      redirect_to root_path
	    end
		@company = Company.find(@current_user.company_id)
		
		@milestone = Milestone.new
		@milestones = Milestone.where(:project_id => params[:id])
		@milestone_infos = Milestone.milestone_infos(@milestones)
		@tasks = Task.where(:project_id => params[:id], :company_id => @company.id)

		if ProjectUser.exists?(:project_id => params[:id], :user_id => @current_user.id) || @current_user.role == 'Manager'
			@users_in = ProjectUser.where(:project_id => params[:id]).collect(&:user)
			@table = ProjectUser.where(:project_id => params[:id]).collect(&:user_id)
			if @table.length > 0
				@users_sel = User.where('id NOT IN (?) and company_id = ?', @table, @company.id)
			else
				@users_sel = User.where(:company_id => @company.id)
			end
			@clients = User.where(:role => 'Client', :company_id => @company.id)
			@project = Project.find(params[:id])
			@users = User.where('role != ? and company_id = ?', 'Client', @company.id)
			client_names = User.joins(:projects).where(:role => 'Client', :company_id => @company.id, :projects => {:id => params[:id]})
			if client_names != nil
				@project_infos = {'client_name' => client_names,'created_at' => @project.created_at.strftime("%F %I:%M%p")  }
			else 
				@project_infos = {'client_name' => nil,'created_at' => @project.created_at.strftime("%F %I:%M%p")  }
			end
		else
			redirect_to root_path
		end
	end	

	def new
	    role = Role.find(@current_user.role_id)
	    if role.permissions[0].to_f % 2 == 0
	      redirect_to root_path
	    end
		@company = Company.find(@current_user.company_id)
		@clients = User.where(:role => 'Client', :company_id => @company.id)
		@project = Project.new
	end

	def edit
	    role = Role.find(@current_user.role_id)
	    if role.permissions[0].to_f % 2 == 0
	      redirect_to root_path
	    end
		@company = Company.find(@current_user.company_id)
		@clients = User.where(:role => 'Client', :company_id => @company.id)
		@project = Project.find(params[:id])
		@users = User.where('role != ? and company_id = ?', 'Client', @company.id)
	end

	def create
	    role = Role.find(@current_user.role_id)
	    if role.permissions[0].to_f % 2 == 0
	      redirect_to root_path
	    end
		@company = Company.find(@current_user.company_id)
		@clients = User.where(:role => 'Client', :company_id => @company.id)
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
	    role = Role.find(@current_user.role_id)
	    if role.permissions[0].to_f % 2 == 0
	      redirect_to root_path
	    end
		@company = Company.find(@current_user.company_id)
		@project = Project.find(params[:id]) 
		@users = User.where('role != ? and company_id = ?', 'Client', @company.id)
		@user = User.find(params[:client])
		if !ProjectUser.exists?(:user => @user,:project => @project)
			ProjectUser.create({:user => @user, :project => @project})
		end

		if @project.update(project_params)
			redirect_to @project
		else
			render 'edit'
		end
	end

	def destroy
	    role = Role.find(@current_user.role_id)
	    if role.permissions[0].to_f % 2 == 0
	      redirect_to root_path
	    end
		@company = Company.find(@current_user.company_id)	
		@project = Project.find(params[:id])
		@project.destroy
		@users = User.where('role != ? and company_id = ?', 'Client', @company.id)
 
		redirect_to projects_path
	end

	private
	def project_params
		params.require(:project).permit(:title, :text, :company_id)
	end

end
