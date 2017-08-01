 class ReportsController < ApplicationController
	before_action :manager_user, :only => [:index, :by_user, :by_project, :get_gantt]

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
		if request.referrer == 'http://localhost:3000/reports/by_user'
			@current_filter = {'year' => session[:reports_year], 'month' => session[:reports_month], 'user' => User.find(session[:reports_user]), 'len' => Time.days_in_month(Date::MONTHNAMES.index(session[:reports_month]))}
		else
			session[:reports_year] = nil
			session[:reports_month] = nil
			session[:reports_user] = nil
			@current_filter = {'year' => @years[20], 'month' => Date::MONTHNAMES[Time.now.month] , 'user' => @users.first, 'len' => Time.days_in_month(Date::MONTHNAMES.index(@months[0]))}
		end
		@data = Report.generate_data(@current_filter)
	end


	def filter
		session[:reports_year] = params[:year]
		session[:reports_month] = params[:month]
		session[:reports_user] = params[:user]
		redirect_to reports_by_user_path
	end

	def get_gantt
		@tasks = Task.where('id in (?)',params[:tasks].tr('[]', '').split(',').map(&:to_i))
		@gant_data = Task.generate_gant_data(@tasks, Time.parse(params[:day].to_s + '-' + Date::MONTHNAMES.index(params[:month]).to_s + '-' + params[:year].to_s), Time.parse(params[:day].to_s + '-' + Date::MONTHNAMES.index(params[:month]).to_s + '-' + params[:year].to_s + ' 23:59:59'))
		@nr = 0
		@tasks.each do |t|
			@nr += @gant_data[t.id]['intervals'].length
		end
		@current_filter = {'year' => params[:year], 'month' => params[:month], 'day' => params[:day], 'user' => User.find(params[:user]),'nr_intervals' => @nr, 'gant_len' => @gant_data.length}
		respond_to do |format|
		  format.json { render json:  {'tasks': @tasks , 'gantt_data': @gant_data , 'helper': @current_filter}}
		end
	end

	def by_project
		@projects = Project.all

		@days=Array.new
		@current_filter = Hash.new
		@aux = Hash.new

		if params[:day] && params[:project]
			@aux = {'day' => params[:day], 'project' => Project.find(params[:project])}
		else
			@aux = {'day' => Time.now.strftime("%m/%d/%Y"), 'project' => @projects.first}
		end

		require 'date'
		DateTime.strptime(@aux['day'], '%m/%d/%Y')
		datetime = DateTime.strptime(@aux['day'], '%m/%d/%Y')

		@current_filter = {'day' => datetime.day, 'month' => datetime.month, 'year' => datetime.year, 'project' => @aux['project']}

		@data = Report.generate_data_project(@current_filter)
	end

end