class WorkDay < ApplicationRecord

	belongs_to :user

	def self.start(work_day)
		if work_day.status != "Started"
				work_day.started_at = Time.now
		end
			@interval = JSON.parse(work_day.interval)
			@interval.push(start_time: Time.now, end_time: nil)
			work_day.interval = JSON.generate(@interval)
			work_day.status = "Started"
			work_day.save
	end

	def self.finish(work_day)
		if work_day.status != "Finished"
				work_day.finished_at = Time.now
				@interval = JSON.parse(work_day.interval)
		end
			work_day.interval = JSON.generate(@interval)
			work_day.status = "Finished"
			work_day.save
	end

	def start_work_day
		@work_day = WorkDay.new
		WorkDay.start(WorkDay.find(params[:work_day]))
		redirect_to :controller => 'dashboards'
	end

	def finish_work_day
		@work_day = WorkDay.where('start_time.today?').first
		WorkDay.finish(WorkDay.find(params[:work_day]))
		redirect_to :controller => 'dashboards'
	end

	def self.get_work_day
		if WorkDay.exists?(:status => "Started")
			return WorkDay.find_by(:status => 'Started')
		else
			return WorkDay.new
		end
	end

	end