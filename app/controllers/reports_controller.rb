class ReportsController < ApplicationController

	before_action :authenticate_user, :only => [:index, :by_user, :by_project, :get_gant]

	def index
	end

	def by_user
		@users = User.where('role != ?', 'Client')
		@months = Array.new
		for i in 1..12
			@months[i-1] = Date::MONTHNAMES[i]
		end
		@years = (Time.now.year - 20 .. Time.now.year).to_a
		@current_filter = Hash.new
		if params[:year] != nil && params[:month] != nil && params[:user] != nil
			@current_filter = {'year' => params[:year], 'month' => params[:month], 'user' => User.find(params[:user]), 'len' => Time.days_in_month(Date::MONTHNAMES.index(params[:month]))}
		else
			@current_filter = {'year' => @years[0], 'month' => @months[0], 'user' => @users.first, 'len' => Time.days_in_month(Date::MONTHNAMES.index(@months[0]))}
		end
		@data = Report.generate_data(@current_filter)
	end

	def get_gant
		@tasks = Task.where('id in (?)',params[:tasks])
		@gant_data = Task.generate_gant_data(@tasks, DateTime.parse(params[:day].to_s + '-' + Date::MONTHNAMES.index(params[:month]).to_s + '-' + params[:year].to_s), DateTime.parse(params[:day].to_s + '-' + Date::MONTHNAMES.index(params[:month]).to_s + '-' + params[:year].to_s + ' 23:59:59'))
	end

	def by_project
	end

end