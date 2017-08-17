class DashboardsController < ApplicationController  
  before_action :authenticate_user

  def index

    if @current_user.type == 'Superuser'
      @companies = Company.all
      render 'index_superuser'
    else
    @company = Company.find(@current_user.company_id)

    @notes = Note.get_notes(@current_user)
    len = @notes.length
    @notes = @notes.first(6)
    case @current_user.role
      #Admin
      when "Admin"
        @admin = User.find(session[:user_id])
        @company = Company.find(@admin.company_id)
        @roles = Role.where(:company_id => @company.id)
        @users = User.where(:type => nil,:company_id => @company.id).order(:role,:username)
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
        @company = Company.find(@current_user.company_id)
        @projects = Project.where(:company_id => @company.id).order(:title)
        @tasks = Task.where(:company_id => @company.id).order(status: :created_at, status: :desc, title: :asc)

        @lengths = {'notes' => len, 'tasks' => @tasks.length, 'projects' => @projects.length}

        @tasks = @tasks.first(10)
        @projects = @projects.first(10)

        @project_infos = Project.create_project_infos(@projects)
        
        @task_infos = Task.create_task_infos(@tasks)

        @users = User.where( :role => 'Employee', :company_id => @company.id)

        this_time = Time.now
        @today = Time.new(this_time.year, this_time.month, this_time.day, 0, 0, 0)

        
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
end