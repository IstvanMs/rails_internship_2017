class TasksController < ApplicationController
	before_action :authenticate_user, :only => [:create, :destroy, :index, :add_task, :start_task, :pause_task, :finish_task]

	def create
		@project = Project.find(params[:project_id])
		@task = @project.tasks.create(task_params)
		if @task.save
			redirect_to :controller => 'tasks' , :action => 'index'
		else
			@users = User.where.not(:role => 'Client')
			render 'add_task'
		end
	end

	def destroy
		@project = Project.find(params[:project_id])
		@task = @project.tasks.find(params[:id])
		@task.destroy
		redirect_to :controller => 'tasks' , :action => 'index'
	end

	def add_task
		@project = Project.find(params[:id])
		@users = User.where.not(:role => 'Client')
	end

	def index
		@projects = Project.all
		if @current_user.role == 'Manager'
			@tasks = Task.all.order(status: :desc, title: :asc)
		else
			@tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc)
		end
	end

	def start_task
		@task = Task.find(params[:task])
		if @task.status != "Started"
			@intervals = JSON.parse(@task.intervals)
			@intervals.push(start_time: Time.now, end_time: nil)
			@task.intervals = JSON.generate(@intervals)
			@task.status = "Started"
			@task.save
		end
		redirect_to :controller => 'tasks' , :action => 'index'
	end

	def pause_task
		@task = Task.find(params[:task])
		if @task.status != "Paused"
			@intervals = JSON.parse(@task.intervals)
			@intervals.last["end_time"] = Time.now
		    @task.intervals = JSON.generate(@intervals)
		    @task.status = "Paused"
		    @task.save
		end
		redirect_to :controller => 'tasks' , :action => 'index'
	end

	def finish_task
		@task = Task.find(params[:task])
		if @task.status != "Finished"
			@intervals = JSON.parse(@task.intervals)

			unless @task.status == 'Paused'
				@intervals.last["end_time"] = Time.now
			end
			@task.intervals = JSON.generate(@intervals)
			@task.status = "Finished"
			@task.save
		end
		redirect_to :controller => 'tasks' , :action => 'index'	
	end

	private
		def task_params
			params.require(:task).permit(:title, :requirement, :task_type, :status, :assigned_user, :intervals)
		end

end
