class DashboardsController < ApplicationController	
  before_action :authenticate_user, :only => [:index]

  def index
    @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)
  	case @current_user.role
      #Admin
      when "Admin"
        @notes = Note.where(:visibility => 'general')
        @notes += Note.where(:visibility => Project.where(:id => Task.where(:assigned_user => @current_user.id).collect{|t| t.project.id}).collect{|p| 'project-' + p.id.to_s})
        @notes += Note.where(:visibility => Task.where(:assigned_user => @current_user.id).collect{|t| 'task-' + t.id.to_s})
        @notes += Note.where(:visibility => 'user-'+ @current_user.id.to_s)
        @notes = @notes.first(6)
        @notes = @notes.sort_by{|n| n.visibility}

        @projects = Project.where(:id => Task.where(:assigned_user => @current_user.id).collect{|t| t.project.id}).order(:title).first(9)
        @users = User.all.order(:role, :username).first(10)
        
        @project_infos = create_project_infos(@projects)

        @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)

        @task_infos = create_task_infos(@tasks)
        render '/layouts/_index_admin'

      #employee
      when 'Employee'
        @notes = Note.where(:visibility => 'general')
        @notes += Note.where(:visibility => Project.where(:id => Task.where(:assigned_user => @current_user.id).collect{|t| t.project.id}).collect{|p| 'project-' + p.id.to_s})
        @notes += Note.where(:visibility => Task.where(:assigned_user => @current_user.id).collect{|t| 'task-' + t.id.to_s})
        @notes += Note.where(:visibility => 'user-'+ @current_user.id.to_s)
        @notes = @notes.first(6)
        @notes = @notes.sort_by{|n| n.visibility}

        @projects = Project.where(:id => Task.where(:assigned_user => @current_user.id).collect{|t| t.project.id}).order(:title).first(9)
        
        @project_infos = create_project_infos(@projects)
        
        @tasks= Task.where(:assigned_user => @current_user.id).order(status: :desc, title: :asc).first(6)

        @task_infos = create_task_infos(@tasks)
        render '/layouts/_index_employee'

      #manager
      when 'Manager'
        @notes=Note.all
        @notes = @notes.first(6)
        @notes = @notes.sort_by{|n| n.visibility}

        @projects = Project.all.order(:title).first(9)
        
        @project_infos = create_project_infos(@projects)
        
        @tasks = Task.all.order(status: :desc, title: :asc).first(6)

        @task_infos = create_task_infos(@tasks)
        render '/layouts/_index_manager'

      #client
      when 'Client'
        @notes = Note.where(:visibility => 'general')
        @notes += Note.where(:visibility => Project.where(:id => ProjectUser.where(:user => User.find(@current_user.id)).collect{|pu| pu.project.id}).collect{|p| 'project-' + p.id.to_s})
        @notes += Note.where(:visibility => Task.where(:project => Project.where(:id => ProjectUser.where(:user => User.find(@current_user.id)).collect{|pu| pu.project.id}).collect{|p| p.id}).collect{|t| 'task-' + t.id.to_s})
        @notes += Note.where(:visibility => 'user-'+ @current_user.id.to_s)
        @notes = @notes.first(6)
        @notes = @notes.sort_by{|n| n.visibility}

        @projects = Project.where(:id => ProjectUser.where(:user => User.find(@current_user.id)).collect{|p| p.project.id}).order(:title).first(9)
        
        @project_infos = create_project_infos(@projects)

        @tasks= Task.where(:project => ProjectUser.where(:user => User.find(@current_user.id)).collect{|p| p.project.id}).order(status: :desc, title: :asc).first(6)
        
        @task_infos = create_task_infos(@tasks)
        render '/layouts/_index_client'
      else puts 'Role error!'
      end
  end

  def create_task_infos(tasks)
    @task_infos = Hash.new
    tasks.each do |t|
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
    return @task_infos
  end

  def create_project_infos(projects)
    @project_infos = Hash.new
    projects.each do |p|
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
    return @project_infos
  end
end
