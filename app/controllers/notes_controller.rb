class NotesController < ApplicationController
	before_action :manager_user, :only => [:new, :create, :destroy]
	
	def index
  	@notes = Note.all
	end

	def show
  	@note = Note.find(params[:id])
	end

	def new
    @users = User.all
    @projects = Project.all
    @tasks = Task.all
		@note = Note.new
	end

	def edit
		@note = Note.find(params[:id])
	end

	def create
	 @note = Note.new(note_params) 
		if @note.save
  		redirect_to @note
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