class WorkDaysController < ApplicationController
    before_action :authenticate_user, :only => [:index, :by_user, :by_project]

    def start_work_day
      @work_day = WorkDay.new
      WorkDay.start(@work_day)
      redirect_to :controller => 'dashboards' , :action => 'index'
    end

    def finish_work_day
      @work_day = WorkDay.where('start_time.today?').first
      WorkDay.finish(WorkDay.where(params[:work_day]))
      redirect_to :controller => 'dashboards' , :action => 'index'
    end

end
