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
		@project_infos = Hash.new
		@projects.each do |p|
			@project_infos[p.id] = {'client_name' => ProjectUser.find_by(:project => p).user.username,'created_at' => p.created_at.strftime("%F %I:%M%p")}
			@tasks = Task.where(:project => p.id)
			@duration = 0
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
				@duration += @time
			end
			@project_infos[p.id] = {'client_name' => ProjectUser.find_by(:project => p).user.username,'created_at' => p.created_at.strftime("%F %I:%M%p"),'duration' => @duration}
		end
	end	

	def show
		@clients = User.where(:role => 'Client')
		@project = Project.find(params[:id])
		@users = User.where.not(:role => 'Client')
		@project_infos = {'client_name' => ProjectUser.find_by(:project => @project).user.username,'created_at' => @project.created_at.strftime("%F %I:%M%p")  }
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
