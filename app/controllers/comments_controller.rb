class CommentsController < ApplicationController
	before_action :authenticate_user

	def reply
	end

	def create
		@task = Task.find(params[:task_id])
		@comment = @task.comments.create({ :user => User.find(comment_params['user']), :text => comment_params['text'], :reply_to => comment_params['reply_to']})
		redirect_to task_path(@task)
	end

	def destroy
		@task = Task.find(params[:task_id])
		@comment = @task.comments.find(params[:id])
		if @comment.user == @current_user || @current_user.role == 'Manager'
			@comment.destroy	
		end
		redirect_to task_path(@task)
	end

	private
		def comment_params
			params.require(:comment).permit(:user, :text, :reply_to)
		end
end
