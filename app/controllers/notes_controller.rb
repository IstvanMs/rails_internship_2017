class NotesController < ApplicationController
	before_action :manager_user, :only => [:new, :edit, :create, :destroy, :update]
  before_action :authenticate_user, :only => [:show, :index]
	
	def index
    @company = Company.find(@current_user.company_id)
    case @current_user.role
    when 'Manager'
      @notes = Note.where(:company_id => @company.id)
    when 'Client'
      @table = Project.joins(:tasks , :projectUsers => :user ).where(:project_users => { :user_id => @current_user}).uniq
      @notes = Note.where(:visibility => 'general', :company_id => @company.id)
      @notes += Note.where(:visibility => @table.collect{|p| 'project-'+p.id.to_s}, :company_id => @company.id)
      @notes += Note.where(:visibility => @table.collect(&:task_ids).uniq.flatten.collect{|id| 'task-' + id.to_s}, :company_id => @company.id)
      @notes += Note.where(:visibility => 'user-'+ @current_user.id.to_s, :company_id => @company.id)
    else
      @notes = Note.where(:visibility => 'general', :company_id => @company.id)
      @notes += Note.where(:visibility => ProjectUser.where(:user_id => @current_user.id).collect{|p| 'project-' + p.project_id.to_s}, :company_id => @company.id)
      @notes += Note.where(:visibility => Task.where(:assigned_user => @current_user).collect{|t| 'task-' + t.id.to_s}, :company_id => @company.id)
      @notes += Note.where(:visibility => 'user-'+ @current_user.id.to_s, :company_id => @company.id)
    end
    @notes = Note.where(:id => @notes.collect(&:id)).order(:visibility)
    @lengths = {'notes' => @notes.length}
    @notes = @notes.paginate(:page => params[:page], :per_page => 50)
  end

	def show
    @company = Company.find(@current_user.company_id)
  	@note = Note.find(params[:id])
    proj = ProjectUser.find_by(:project_id  => @note.visibility.split('-')[1], :user_id => @current_user.id)
    task = Task.find_by(:id => @note.visibility.split('-')[1], :assigned_user => @current_user)
    if @current_user.role != 'Manager' 
      if !proj && @note.visibility != ('user-' + @current_user.id.to_s) && !task && @note.visibility != 'general'
        redirect_to root_path
      end
    end
	end

	def new
    @company = Company.find(@current_user.company_id)
    @users = User.where('id != ? and company_id = ?', @current_user.id, @company.id)
    @projects = Project.where(:company_id => @company.id)
    @tasks = Task.where(:company_id => @company.id)
		@note = Note.new
	end

	def edit
    @company = Company.find(@current_user.company_id)
    @users = User.where('id != ? and company_id = ?', @current_user.id, @company.id)
    @projects = Project.where(:company_id => @company.id)
    @tasks = Task.where(:company_id => @company.id)
		@note = Note.find(params[:id])
	end

	def create
    @company = Company.find(@current_user.company_id)
    @users = User.where('id != ? and company_id = ?', @current_user.id, @company.id)
    @projects = Project.where(:company_id => @company.id)
    @tasks = Task.where(:company_id => @company.id)
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
    @note.company_id = params[:note][:company_id]
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
    	params.require(:note).permit(:text, :visibility, :company_id)
  	end

end