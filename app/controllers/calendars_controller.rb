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

	def get_more_info
		st = Time.new(params[:year], params[:month], params[:day], 0, 0, 0)
		events = Event.where('start_time > ? and start_time < ? and company_id = ?', st, st.next_day, @current_user.company_id)
		respond_to do |format|
			format.json { render json:  {'events': events, 'len': events.length}}
		end
	end

	def monthly
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
	end
end
