class ReportsController < ApplicationController
	before_action :manager_user, :only => [:index, :by_user, :by_project, :get_gant]

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
			@current_filter = {'year' => @years[20], 'month' => Date::MONTHNAMES[Time.now.month] , 'user' => @users.first, 'len' => Time.days_in_month(Date::MONTHNAMES.index(@months[0]))}
		end
		@data = Report.generate_data(@current_filter)
	end

	def get_gant
		@tasks = Task.where('id in (?)',params[:tasks])
		@gant_data = Task.generate_gant_data(@tasks, Time.parse(params[:day].to_s + '-' + Date::MONTHNAMES.index(params[:month]).to_s + '-' + params[:year].to_s), Time.parse(params[:day].to_s + '-' + Date::MONTHNAMES.index(params[:month]).to_s + '-' + params[:year].to_s + ' 23:59:59'))
		@nr = 0
		@tasks.each do |t|
			@nr += @gant_data[t.id]['intervals'].length
		end
		puts @nr
		puts @gant_data
		@current_filter = {'year' => params[:year], 'month' => params[:month], 'day' => params[:day], 'user' => User.find(params[:user]),'nr_intervals' => @nr}
	end

	def by_project

		@projects = Project

		@days=Array.new

		@current_filter = Hash.new

		if params[:day] != nil && params[:project] != nil
			@current_filter = {'day' => params[:day], 'project' => Project.find(params[:project]), 'len' => Project.find(params[:project]).tasks.all.length}
		else
			@current_filter = {'day' => Time.now.strftime("%d/%m/%Y"), 'project' => @projects.first, 'len' => @projects.first.tasks.length}
		end
		
		@data = Report.generate_data_project(@current_filter)

	end

end