class MessagesController < ApplicationController
	before_action :authenticate_user

	def new
		@message = Message.new
		@users = User.where('company_id = ? and id != ?', @current_user.company_id, @current_user.id)
	end

	def create
		@message = Message.new(message_params)
		@users = User.where('company_id = ? and id != ?', @current_user.company_id, @current_user.id)

		if @message.save
			redirect_to message_path(@message)
		else
			render 'new'
		end
	end

	def reply
		@rep = Message.find(params[:id])
		@message = Message.new
	end

	def set_read
		@message = Message.find(params[:id])
		@message.update_attribute(:status, 'read')
	end

	def index
		@outbox = Message.where(:sender_id => @current_user.id)
		@inbox = Message.where(:recipient_id => @current_user.id)
		@users = User.where(:company_id => @current_user.company_id)
	end

	def show
		@message = Message.find(params[:id])
		@sender = User.find(@message.sender_id)
		@recipient = User.find(@message.recipient_id)
		if @recipient != @current_user && @sender != @current_user
			redirect_to root_path
		end
		if @recipient == @current_user
			@message.update_attribute(:status, 'read') 
		end
	end

	private
		def message_params
			params.require(:message).permit(:sender_id, :recipient_id, :status, :subject, :content)
		end
end
