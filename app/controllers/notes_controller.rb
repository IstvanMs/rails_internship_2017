class NotesController < ApplicationController
	before_action :manager_user, :only => [:new, :edit, :create, :destroy, :update]
  before_action :authenticate_user, :only => [:show, :index]
	
	def index
    case @current_user.role
    when 'Manager'
      @notes = Note.all
    when 'Client'
      @table = Project.joins(:tasks , :projectUsers => :user ).where(:project_users => { :user_id => @current_user}).uniq
      @notes = Note.where(:visibility => 'general')
      @notes += Note.where(:visibility => @table.collect{|p| 'project-'+p.id.to_s})
      @notes += Note.where(:visibility => @table.collect(&:task_ids).uniq.flatten.collect{|id| 'task-' + id.to_s})
      @notes += Note.where(:visibility => 'user-'+ @current_user.id.to_s)
    else
      @table = Project.joins(:tasks).where(:tasks => { :assigned_user => @current_user}).uniq
      @notes = Note.where(:visibility => 'general')
      @notes += Note.where(:visibility => @table.collect{|p| 'project-' + p.id.to_s})
      @notes += Note.where(:visibility => @table.collect(&:task_ids).uniq.flatten.collect{|id| 'task-' + id.to_s})
      @notes += Note.where(:visibility => 'user-'+ @current_user.id.to_s)
    end
    @notes = Note.where(:id => @notes.collect(&:id)).order(:visibility)
    @notes = @notes.paginate(:page => params[:page], :per_page => 50)
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