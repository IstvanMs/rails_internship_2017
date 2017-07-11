class DashboardsController < ApplicationController	
  before_action :authenticate_user, :only => [:index]

  def index
    @projects = Project.all
    @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)
  	case @current_user.role
      when "Admin"
        @users = User.all.order(:role, :username).first(10)
        @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)
        render '/layouts/_index_admin'
      when 'Employee'
        @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)
        render '/layouts/_index_employee'
      when 'Manager'
        @tasks = Task.all.order(status: :desc, title: :asc).first(6)
        render '/layouts/_index_manager'
      when 'Client'
        render '/layouts/_index_client'
      else puts 'Role error!'
      end
  end
end
