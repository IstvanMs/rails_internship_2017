class WorkDaysController < ApplicationController
    before_action :authenticate_user, :only => [:index, :by_user, :by_project]

    def start_work_day
      @work_day = WorkDay.new
      WorkDay.start(@work_day)
      redirect_to :controller => 'dashboards' , :action => 'index'
    end

    def finish_work_day
      @work_day = WorkDay.get_work_day
      WorkDay.finish(@work_day)
      redirect_to :controller => 'dashboards' , :action => 'index'
    end
end
