class TasksController < ApplicationController
	before_action :authenticate_user

	def create
		@role = Role.find(@current_user.role_id)
		if (@role.permissions[1].to_f / 2) % 2 != 1
			redirect_to root_path
		else
			@company = Company.find(@current_user.company_id)
			@project = Project.find(params[:project_id])
			@task = @project.tasks.create(task_params)
			@user = User.find(@task.assigned_user)
			if @task.save
				MailerMailer.assigned_to_task(@user, @task).deliver
				redirect_to :controller => 'tasks' , :action => 'index'
			else
				@users = User.where('role != ? and role != ?', 'Client', 'Manager')
				render 'add_task'
			end
		end
	end

	def show
		@role = Role.find(@current_user.role_id)
		if @role.permissions[1].to_f < 1
			redirect_to root_path
		else
			@company = Company.find(@current_user.company_id)
			@task = Task.find(params[:id])
			if User.exists?(@task.assigned_user)
				@assigned_user = User.find(@task.assigned_user)
			else
				@assigned_user = nil
			end
		end
	end

	def edit
		@role = Role.find(@current_user.role_id)
		if (@role.permissions[1].to_f / 2) % 2 != 1
			redirect_to root_path
		else
			@company = Company.find(@current_user.company_id)
			@task = Task.find(params[:id])
			@project = Project.find(@task.project_id)
			@users = User.where('role != ? and role != ? and company_id = ?', 'Client', 'Manager', @company.id)
		end
	end

	def update
		@role = Role.find(@current_user.role_id)
		if (@role.permissions[1].to_f / 2) % 2 != 1
			redirect_to root_path
		else
			@company = Company.find(@current_user.company_id)
			@task = Task.find(params[:id])
			@project = Project.find(@task.project_id)
			@users = User.where('role != ? and role != ? and company_id = ?', 'Client', 'Manager', @company.id)
			
			if @task.update(task_params)
				redirect_to @task
			else
				render 'edit'
			end
		end
	end

	def search
		redirect_to tasks_index_path(:search => params[:search])
	end

	def destroy
		@role = Role.find(@current_user.role_id)
		if (@role.permissions[1].to_f / 2) % 2 != 1
			redirect_to root_path
		else
			@company = Company.find(@current_user.company_id)
			@project = Project.find(params[:project_id])
			@task = @project.tasks.find(params[:id])
			@task.destroy
			redirect_to :controller => 'tasks' , :action => 'index'
		end
	end

	def add_task
		@role = Role.find(@current_user.role_id)
		if (@role.permissions[1].to_f / 2) % 2 != 1
			redirect_to root_path
		else
			@company = Company.find(@current_user.company_id)
			@project = Project.find(params[:id])
			@users = User.where('role != ? and role != ? and company_id = ?', 'Client', 'Manager', @company.id)
		end
	end

	def index
		@role = Role.find(@current_user.role_id)

		if @role.permissions[1].to_f < 1
			redirect_to root_path
		else
			@company = Company.find(@current_user.company_id)

			@projects = Project.where(:company_id => @company.id)
			if @current_user.role == 'Manager'
				@tasks = Task.where(:company_id => @company.id).order(status: :desc, title: :asc)
			else
				if @current_user.role != 'Client'
					@tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc)
				else
					@tasks= Task.where(:project => ProjectUser.joins(:user).where(:user => @current_user).collect(&:project_id)).order(status: :desc, title: :asc)
				end
			end
			
        	@work_day = WorkDay.get_work_day(@current_user.id)

			@lengths = {'tasks' => @tasks.length}

			if params[:advanced_search_id] != nil
				@tasks = AdvancedSearch.tasks_filter(params[:advanced_search_id], @current_user.id)
				@advanced_search = AdvancedSearch.find(params[:advanced_search_id])
			end

			if @tasks
				@tasks = @tasks.paginate(:page => params[:page], :per_page => 50)
				@task_infos = Task.create_task_infos(@tasks)
			end 
		end
	end

	def start_task
		@role = Role.find(@current_user.role_id)
		if @role.permissions[1].to_f % 2 != 1
			redirect_to root_path
		else
			@task = Task.find_by(:status => 'Started')
			if @task != nil
				Task.pause(@task)
			end
			Task.start(Task.find(params[:task]))
			redirect_to request.env['HTTP_REFERER']
		end
	end

	def pause_task
		@role = Role.find(@current_user.role_id)
		if @role.permissions[1].to_f % 2 != 1
			redirect_to root_path
		else
			Task.pause(Task.find(params[:task]))
			redirect_to request.env['HTTP_REFERER']
		end
	end

	def finish_task
		@role = Role.find(@current_user.role_id)
		if @role.permissions[1].to_f % 2 != 1
			redirect_to root_path
		else
			Task.finish(Task.find(params[:task]))
			redirect_to request.env['HTTP_REFERER']
		end
	end

	def pause_current_task
		@role = Role.find(@current_user.role_id)
		if @role.permissions[1].to_f % 2 != 1
			redirect_to root_path
		else
			Task.pause(Task.find(params[:task]))
			redirect_to request.env['HTTP_REFERER']
		end
	end

	def create_advanced_search
		@role = Role.find(@current_user.role_id)

		if @role.permissions[1].to_f < 1
			redirect_to root_path
		else
			@advanced_search = AdvancedSearch.create!(params[:advanced_search])
			redirect_to "/tasks/index/#{@advanced_search.id}"
		end
	end

	def show_advanced_search
		@role = Role.find(@current_user.role_id)

		if @role.permissions[1].to_f < 1
			redirect_to root_path
		else
			@advanced_search = AdvancedSearch.find(params[:id])
		end
	end

	private
		def task_params
			params.require(:task).permit(:title, :requirement, :task_type, :status, :assigned_user, :intervals, :company_id, :milestone_id)
		end

end
