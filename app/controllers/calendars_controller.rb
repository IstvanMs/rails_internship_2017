class CalendarsController < ApplicationController
	before_action :authenticate_user

	def index
		if @current_user.type == 'Superuser'
			redirect_to root_path
		else
			role = Role.find(@current_user.role_id)
			if role.permissions[5].to_i < 0
				redirect_to root_path 
			else
			end
		end
	end

	def get_event_info
		event = Event.find(params[:id])
		respond_to do |format|
			format.json { render json:  event}
		end
	end

	def monthly
		@company = Company.find(@current_user.company_id)
		@role = Role.find(@current_user.role_id)
		@current_filter = Hash.new
		if params[:year] && params[:month]
			@current_filter = {'year' => params[:year], 'month' => params[:month], 'days' => Time.days_in_month(Date::MONTHNAMES.index(params[:month])) }
		else
			@current_filter = {'year' => Time.now.year, 'month' => Date::MONTHNAMES[Time.now.month], 'days' => Time.days_in_month(Time.now.month) }
		end
		@years = (Time.now.year - 20 .. Time.now.year).to_a
		@months = Array.new 
		for i in 1..12
			@months[i-1] = Date::MONTHNAMES[i]
		end
	end

	def weekly
		@company = Company.find(@current_user.company_id)
		@role = Role.find(@current_user.role_id)
		@current_filter = nil
		if params[:week]
			if params[:week] != ''
				week = params[:week].split(' - ')
				@current_filter = params[:week]
				st = Date.parse(week[0].strip) 
				et = Date.parse(week[1].strip)
				@current_filter = {'start' => st, 'end' => et}
				@events = Event.getEvents(st, et, @company)
				puts @events
			else
				d = Date.today
				st = d.at_beginning_of_week
				et = d.at_beginning_of_week + 6.days
				@current_filter = {'start' => st, 'end' => et}
				@events = Event.getEvents(st, et, @company)
				puts @events
			end
		else
			d = Date.today
			st = d.at_beginning_of_week
			et = d.at_beginning_of_week + 6.days
			@current_filter = {'start' => st, 'end' => et}
			@events = Event.getEvents(st, et, @company)
			puts @events
		end
	end
end
