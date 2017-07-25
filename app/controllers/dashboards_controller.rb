class DashboardsController < ApplicationController	
  before_action :authenticate_user, :only => [:index]

  def index
    @notes = Note.get_notes(@current_user).first(6)
    case @current_user.role
      #Admin
      when "Admin"
        @users = User.all.order(:role, :username).first(10)

        @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)
        @task_infos = Task.create_task_infos(@tasks)

        @projects = Project.where(:id => @tasks.collect(&:project_id)).order(:title).first(9)
        @project_infos = Project.create_project_infos(@projects)

        render 'index_admin'

      #employee
      when 'Employee'
        @tasks= Task.where(:assigned_user => @current_user.id).order(status: :created_at, status: :desc, title: :asc).first(10)
        @task_infos = Task.create_task_infos(@tasks)

        @projects = Project.where(:id => @tasks.collect(&:project_id)).order(:title).first(9)
        @project_infos = Project.create_project_infos(@projects)

        @work_days = WorkDay.get_work_day
        #puts @work_day

        render 'index_employee'

      #manager
      when 'Manager'
        @projects = Project.all.order(:title).first(9)
        @project_infos = Project.create_project_infos(@projects)
        
        @tasks = Task.all.order(status: :created_at, status: :desc, title: :asc).first(10)
        @task_infos = Task.create_task_infos(@tasks)
        
        render 'index_manager'

      #client
      when 'Client'
        @projects = @current_user.projects.order(:title).first(9)
        @project_infos = Project.create_project_infos(@projects)

        @tasks = Task.where(:project => ProjectUser.joins(:user).where(:user => @current_user).collect(&:project_id)).order(status: :desc, title: :asc).first(6)
        @task_infos = Task.create_task_infos(@tasks)

        render 'index_client'
      else puts 'Role error!'
      end
  end
end
