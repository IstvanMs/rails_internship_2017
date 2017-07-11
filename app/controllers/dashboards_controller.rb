class DashboardsController < ApplicationController	
  before_action :authenticate_user, :only => [:index]

  def index
    @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)
  	case @current_user.role
      when "Admin"
        @projects = Project.where(:id => Task.where(:assigned_user => @current_user.id).collect{|t| t.project.id}).order(:title).first(6)
        @users = User.all.order(:role, :username).first(10)
        @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)
        render '/layouts/_index_admin'
      when 'Employee'
        @projects = Project.where(:id => Task.where(:assigned_user => @current_user.id).collect{|t| t.project.id}).order(:title).first(6)
        @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)
        render '/layouts/_index_employee'
      when 'Manager'
        @projects = Project.all.order(:title).first(6)
        @tasks = Task.all.order(status: :desc, title: :asc).first(6)
        render '/layouts/_index_manager'
      when 'Client'
        @projects = Project.where(:id => ProjectUser.where(:user => User.find(@current_user.id)).collect{|p| p.project.id}).order(:title).first(6)
        @tasks= Task.where(:project => ProjectUser.where(:user => User.find(@current_user.id)).collect{|p| p.project.id})
        render '/layouts/_index_client'
      else puts 'Role error!'
      end
  end
end
