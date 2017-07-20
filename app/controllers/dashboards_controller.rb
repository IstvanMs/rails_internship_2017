class DashboardsController < ApplicationController	
  before_action :authenticate_user, :only => [:index]

  def index
    @notes = Note.get_notes(@current_user).first(6)
    case @current_user.role
      #Admin
      when "Admin"
        @users = User.all.order(:role, :username).first(10)

        @projects = Project.where(:id => Task.where(:assigned_user => @current_user.id).collect{|t| t.project.id}).order(:title).first(9)
        @project_infos = Project.create_project_infos(@projects)

        @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)
        @task_infos = Task.create_task_infos(@tasks)
        render 'index_admin'

      #employee
      when 'Employee'
        @projects = Project.where(:id => Task.where(:assigned_user => @current_user.id).collect{|t| t.project.id}).order(:title).first(9)
        @project_infos = Project.create_project_infos(@projects)
        
        @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)
        @task_infos = Task.create_task_infos(@tasks)
        render 'index_employee'

      #manager
      when 'Manager'
        @projects = Project.all.order(:title).first(9)
        @project_infos = Project.create_project_infos(@projects)
        
        @tasks = Task.all.order(status: :desc, title: :asc).first(6)
        @task_infos = Task.create_task_infos(@tasks)
        render 'index_manager'

      #client
      when 'Client'
        @projects = @current_user.projects.order(:title).first(9)
        @project_infos = Project.create_project_infos(@projects)
        @tasks = Task.where(:project => ProjectUser.where(:user => User.find(@current_user.id)).collect{|p| p.project.id}).order(status: :desc, title: :asc).first(6)
        @task_infos = Task.create_task_infos(@tasks)
        render 'index_client'
      else puts 'Role error!'
      end
  end
end
