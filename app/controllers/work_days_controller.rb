class WorkDaysController < ApplicationController
    before_action :authenticate_user, :only => [:start_work_day, :finish_work_day]

    def start_work_day
      @work_day = WorkDay.new
      WorkDay.start(@work_day, @current_user.id)
      redirect_to :controller => 'dashboards' , :action => 'index'
    end

    def finish_work_day
      @work_day = WorkDay.get_work_day(@current_user.id)
      WorkDay.finish(@work_day)
      redirect_to :controller => 'dashboards' , :action => 'index'
    end

    def un_end_work_day
      @work_day = WorkDay.get_work_day(params[:user_id])
      WorkDay.un_end(@work_day)
      redirect_to :controller => 'dashboards' , :action => 'index'
    end
end
