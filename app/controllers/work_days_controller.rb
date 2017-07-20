class WorkDaysController < ApplicationController
	before_action :authenticate_user, :only => [:index, :by_user, :by_project]

	def index
		work_day = WorkDay.get_work_day
		puts work_day
	end

	def start_work_day

		WorkDay.start(WorkDay.find(params[:work_day]))
		redirect_to :controller => 'dashboards' , :action => 'index'

	end

	def finish_work_day

		WorkDay.finish(WorkDay.find(params[:work_day]))
		redirect_to :controller => 'dashboards' , :action => 'index'

	end

end
