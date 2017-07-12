class DashboardsController < ApplicationController	
  before_action :authenticate_user, :only => [:index]

  def index
    #default
    @notes=Note.all
    @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)
  	case @current_user.role
      when "Admin"
        @projects = Project.where(:id => Task.where(:assigned_user => @current_user.id).collect{|t| t.project.id}).order(:title).first(6)
        @users = User.all.order(:role, :username).first(10)
        @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)
        @clients = Hash.new
        @projects.each do |p|
          @clients[p.id] = ProjectUser.find_by(:project => p).user.username
        end
        @assigneds = Hash.new
        @clients_tasks = Hash.new 
        @tasks.each do |t|
          @assigneds[t.id] = User.find(t.assigned_user).username
          @clients_tasks[t.id] = ProjectUser.find_by(:project => t.project).user.username
        end
        
        render '/layouts/_index_admin'
      when 'Employee'
        @projects = Project.where(:id => Task.where(:assigned_user => @current_user.id).collect{|t| t.project.id}).order(:title).first(6)
        @clients = Hash.new
        @projects.each do |p|
          @clients[p.id] = ProjectUser.find_by(:project => p).user.username
        end
        @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)
        @clients = Hash.new
        @projects.each do |p|
          @clients[p.id] = ProjectUser.find_by(:project => p).user.username
        end
        @assigneds = Hash.new
        @clients_tasks = Hash.new 
        @tasks.each do |t|
          @assigneds[t.id] = User.find(t.assigned_user).username
          @clients_tasks[t.id] = ProjectUser.find_by(:project => t.project).user.username
        end
        render '/layouts/_index_employee'
      when 'Manager'
        @projects = Project.all.order(:title).first(6)
        @clients = Hash.new
        @projects.each do |p|
          @clients[p.id] = ProjectUser.find_by(:project => p).user.username
        end
        @tasks = Task.all.order(status: :desc, title: :asc).first(6)
        @assigneds = Hash.new
        @clients_tasks = Hash.new 
        @tasks.each do |t|
          @assigneds[t.id] = User.find(t.assigned_user).username
          @clients_tasks[t.id] = ProjectUser.find_by(:project => t.project).user.username
        end
        render '/layouts/_index_manager'
      when 'Client'
        @projects = Project.where(:id => ProjectUser.where(:user => User.find(@current_user.id)).collect{|p| p.project.id}).order(:title).first(6)
        @clients = Hash.new
        @projects.each do |p|
          @clients[p.id] = ProjectUser.find_by(:project => p).user.username
        end
        @tasks= Task.where(:project => ProjectUser.where(:user => User.find(@current_user.id)).collect{|p| p.project.id})
        @assigneds = Hash.new
        @clients_tasks = Hash.new 
        @tasks.each do |t|
          @assigneds[t.id] = User.find(t.assigned_user).username
          @clients_tasks[t.id] = ProjectUser.find_by(:project => t.project).user.username
        end
        render '/layouts/_index_client'
      else puts 'Role error!'
      end
  end
end
