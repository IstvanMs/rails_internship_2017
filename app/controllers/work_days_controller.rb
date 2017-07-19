class WorkDaysController < ApplicationController
	before_action :authenticate_user, :only => [:index, :by_user, :by_project]

	def index
	end

	def start_workDay

		WorkDay.start(WorkDay)
		redirect_to :controller => 'workDays' , :action => 'index'

	end

	def finish_workDay

		WorkDay.finish(WorkDay)
		redirect_to :controller => 'workDays' , :action => 'index'	

	end

end
