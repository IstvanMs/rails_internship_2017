class NotesController < ApplicationController
	before_action :manager_user, :only => [:new, :edit, :create, :destroy, :update]
  before_action :authenticate_user, :only => [:show, :index]
	
	def index
    case @current_user.role
    when 'Manager'
      @notes = Note.all
    when 'Client'
      @notes = Note.where(:visibility => 'general')
      @notes += Note.where(:visibility => Project.where(:id => ProjectUser.where(:user => User.find(@current_user.id)).collect{|pu| pu.project.id}).collect{|p| 'project-' + p.id.to_s})
      @notes += Note.where(:visibility => Task.where(:project => Project.where(:id => ProjectUser.where(:user => User.find(@current_user.id)).collect{|pu| pu.project.id}).collect{|p| p.id}).collect{|t| 'task-' + t.id.to_s})
      @notes += Note.where(:visibility => 'user-'+ @current_user.id.to_s)
    else
      @notes = Note.where(:visibility => 'general')
      @notes += Note.where(:visibility => Project.where(:id => Task.where(:assigned_user => @current_user.id).collect{|t| t.project.id}).collect{|p| 'project-' + p.id.to_s})
      @notes += Note.where(:visibility => Task.where(:assigned_user => @current_user.id).collect{|t| 'task-' + t.id.to_s})
      @notes += Note.where(:visibility => 'user-'+ @current_user.id.to_s)
    end
	end

	def show
  	@note = Note.find(params[:id])
	end

	def new
    @users = User.where.not(:id => @current_user.id)
    @projects = Project.all
    @tasks = Task.all
		@note = Note.new
	end

	def edit
    @users = User.where.not(:id => @current_user.id)
    @projects = Project.all
    @tasks = Task.all
		@note = Note.find(params[:id])
	end

	def create
    @users = User.where.not(:id => @current_user.id)
    @projects = Project.all
    @tasks = Task.all
    @note = Note.new
    @note.text = params[:note][:text]
    case(params[:note_type])
      when '1'
        @note.visibility = 'general'
      when '2'
        @note.visibility = 'project-'+params[:selected_id]
      when '3'
        @note.visibility = 'task-'+params[:selected_id]
      when '4'
        @note.visibility = 'user-'+params[:selected_id]
      else puts 'Type error!'
    end
		if @note.save
  		redirect_to notes_path
		else
  		render 'new'
		end
	end

	def update
		@note = Note.find(params[:id])

		if @note.update(note_params)
  		redirect_to @note
		else
  		render 'edit'
		end
	end

	def destroy
		@note = Note.find(params[:id])
		@note.destroy

		redirect_to notes_path
	end

	private
  	def note_params
    	params.require(:note).permit(:text, :visibility)
  	end

end