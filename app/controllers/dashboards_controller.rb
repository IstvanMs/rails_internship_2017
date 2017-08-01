class DashboardsController < ApplicationController	
  before_action :authenticate_user, :only => [:index]

  def index
    @notes = Note.get_notes(@current_user)
    len = @notes.length
    @notes = @notes.first(6)
    case @current_user.role
      #Admin
      when "Admin"
        @users = User.all.order(:role, :username)
        @users = @users.first(10)

        @tasks = Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc)
        @projects = @current_user.projects.order(:title)

        @lengths = {'notes' => len, 'tasks' => @tasks.length, 'projects' => @projects.length}
        @tasks = @tasks.first(10)

        @projects = @projects.first(10)

        @task_infos = Task.create_task_infos(@tasks)

        @project_infos = Project.create_project_infos(@projects)

        render 'index_admin'

      #employee
      when 'Employee'
        @tasks= Task.where(:assigned_user => @current_user.id).order(status: :created_at, status: :desc, title: :asc).first(10)
        @projects = @current_user.projects.order(:title)
        
        @lengths = {'notes' => len, 'tasks' => @tasks.length, 'projects' => @projects.length}

        @tasks = @tasks.first(10)
        @projects = @projects.first(10)

        @task_infos = Task.create_task_infos(@tasks)

        @project_infos = Project.create_project_infos(@projects)

        @work_day = WorkDay.get_work_day(@current_user.id)

        render 'index_employee'

      #manager
      when 'Manager'
        @projects = Project.all.order(:title)
        @tasks = Task.all.order(status: :created_at, status: :desc, title: :asc)

        @lengths = {'notes' => len, 'tasks' => @tasks.length, 'projects' => @projects.length}

        @tasks = @tasks.first(10)
        @projects = @projects.first(10)

        @project_infos = Project.create_project_infos(@projects)
        
        @task_infos = Task.create_task_infos(@tasks)

        @users = User.where( :role => 'Employee' )
        
        render 'index_manager'

      #client
      when 'Client'
        @projects = @current_user.projects.order(:title)
        @tasks = Task.where(:project => ProjectUser.joins(:user).where(:user => @current_user).collect(&:project_id)).order(status: :desc, title: :asc)

        @lengths = {'notes' => len, 'tasks' => @tasks.length, 'projects' => @projects.length}

        @tasks = @tasks.first(10)
        @projects = @projects.first(10)

        @project_infos = Project.create_project_infos(@projects)

        @task_infos = Task.create_task_infos(@tasks)

        render 'index_client'
      else puts 'Role error!'
      end
  end
end
