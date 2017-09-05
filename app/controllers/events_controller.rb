class EventsController < ApplicationController
	before_action :authenticate_user

	def create
		@errors = Hash.new
		if !params[:day] || params[:day] == '' 
			@errors['Day'] = ' required!'
		end
		if event_params[:name].blank?
			@errors['Name'] = " can't be blank!"
		end
		if event_params[:content].blank?
			@errors['Content'] = " can't be blank!"
		end
		if event_params[:start_time].blank?
			@errors['Start time'] = " can't be blank!"
		end
		if event_params[:end_time].blank?
			@errors['End time'] = " can't be blank!"
		end
		if !event_params[:start_time].blank? && !event_params[:end_time].blank?
			if Time.parse(event_params[:end_time]) < Time.parse(event_params[:start_time])
				@errors['Time'] = " start time can't be greater than end time!"
			end
		end
		if @errors.length <= 0
			st = DateTime.parse(params[:day] + ' ' + event_params[:start_time])
			et = DateTime.parse(params[:day] + ' ' + event_params[:end_time])
			event = Event.new({:name => event_params[:name], :content => event_params[:content], :is_conference => event_params[:is_conference], :start_time => event_params[:start_time], :end_time => event_params[:end_time], :company_id => event_params[:company_id]})
			event.save
		end
		redirect_to :controller => 'calendars', :action => 'monthly'
	end

	def destroy
		event = Event.find(params[:id])
		event.destroy

		redirect_to :controller => 'calendars', :action => 'monthly'
	end

	private
		def event_params
			params.require(:event).permit(:name, :content, :is_conference, :start_time, :end_time, :company_id)
		end
end
