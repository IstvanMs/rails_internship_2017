class TasksController < ApplicationController
	before_action :authenticate_user, :only => [:index, :start_task, :pause_task, :finish_task, :search]
	before_action :manager_user, :only => [:create, :destroy, :add_task]

	def create
		@project = Project.find(params[:project_id])
		@task = @project.tasks.create(task_params)
		if @task.save
			redirect_to :controller => 'tasks' , :action => 'index'
		else
			@users = User.where('role != ? and role != ?', 'Client', 'Manager')
			render 'add_task'
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
					@tasks= Task.where(:project => ProjectUser.where(:user => User.find(@current_user.id)).collect{|p| p.project.id}).order(status: :desc, title: :asc)
				else
					@tasks= Task.where('project_id in (?) and title like ?', ProjectUser.where(:user => User.find(@current_user.id)).collect{|p| p.project.id}, '%' + @search_par + '%').order(status: :desc, title: :asc)
				end
			end
		end

		@task_infos = Hash.new
		@tasks.each do |t|
			@intervals = JSON.parse(t.intervals)
			@time = 0
			@intervals.each do |i|
				if i['start_time'] != nil && i['end_time'] != nil
					@time += (Time.parse(i['end_time']) - Time.parse(i['start_time']))/60
				end
			end
			if @time != 0
				@time = @time.truncate + 1
			end

			@task_infos[t.id] = {'client_name' => ProjectUser.find_by(:project => t.project).user.username,'assigned' => User.find(t.assigned_user).username,'last_update' => t.updated_at.strftime("%F %I:%M%p"),'duration' => @time,'project_name' => Project.find(t.project.id).title}
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
