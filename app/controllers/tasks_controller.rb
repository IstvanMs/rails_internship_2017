class TasksController < ApplicationController
	before_action :authenticate_user, :only => [:index, :start_task, :pause_task, :finish_task, :search, :show]
	before_action :manager_user, :only => [:create, :destroy, :add_task, :edit]

	def create
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

	def show
		@task = Task.find(params[:id])
		@assigned_user = User.find(@task.assigned_user)
	end

	def edit
		@task = Task.find(params[:id])
		@project = Project.find(@task.project_id)
		@users = User.where('role != ? and role != ?', 'Client', 'Manager')
	end

	def update
		@task = Task.find(params[:id])
		@project = Project.find(@task.project_id)
		@users = User.where('role != ? and role != ?', 'Client', 'Manager')
		
		if @task.update(task_params)
			redirect_to @task
		else
			render 'edit'
		end
	end

	def search
		redirect_to tasks_index_path(:search => params[:search])
	end

	def destroy
		@project = Project.find(params[:project_id])
		@task = @project.tasks.find(params[:id])
		@task.destroy
		redirect_to :controller => 'tasks' , :action => 'index'
	end

	def add_task
		@project = Project.find(params[:id])
		@users = User.where('role != ? and role != ?', 'Client', 'Manager')
	end

	def index
		@projects = Project.all

		@search_par = params[:search]
		
		if @current_user.role == 'Manager'
			if @search_par == nil || @search_par == ''
				@tasks = Task.all.order(status: :desc, title: :asc)
			else
				@tasks = Task.where('title like ?', '%' + @search_par + '%').order(status: :desc, title: :asc)
			end
		else
			if @current_user.role != 'Client'
				if @search_par == nil || @search_par == ''
					@tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc)
				else
					@tasks= Task.where('assigned_user = ? and title like ?', @current_user.id, '%' + @search_par + '%').order(status: :desc, title: :asc)
				end
			else
				if @search_par == nil || @search_par == ''
					@tasks= Task.where(:project => ProjectUser.joins(:user).where(:user => @current_user).collect(&:project_id)).order(status: :desc, title: :asc)
				else
					@tasks= Task.where('project_id in (?) and title like ?', ProjectUser.joins(:user).where(:user => @current_user).collect(&:project_id), '%' + @search_par + '%').order(status: :desc, title: :asc)
				end
			end
		end
		@lengths = {'tasks' => @tasks.length}

		@tasks = @tasks.paginate(:page => params[:page], :per_page => 50)

		@task_infos = Task.create_task_infos(@tasks)
	end

	def start_task
		@task = Task.find_by(:status => 'Started')
		if @task != nil
			Task.pause(@task)
		end
		Task.start(Task.find(params[:task]))
		redirect_to request.env['HTTP_REFERER']
	end

	def pause_task
		Task.pause(Task.find(params[:task]))
		redirect_to request.env['HTTP_REFERER']
	end

	def finish_task
		Task.finish(Task.find(params[:task]))
		redirect_to request.env['HTTP_REFERER']
	end

	def pause_current_task
		Task.pause(Task.find(params[:task]))
		redirect_to request.env['HTTP_REFERER']
	end

	def create_advanced_search
		@advanced_search = AdvancedSearch.create!(params[:advanced_search])
		redirect_to @advanced_search
	end

	def show_advanced_search
		@advanced_search = AdvancedSearch.find(params[:id])
	end

	private
		def task_params
			params.require(:task).permit(:title, :requirement, :task_type, :status, :assigned_user, :intervals)
		end

end
