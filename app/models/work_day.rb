class WorkDay < ApplicationRecord

	belongs_to :user

  def self.pause_all_tasks(user_id)
    @task = Task.find_by(:status => 'Started', :assigned_user => user_id)
    if @task
    Task.pause(@task)
	end
  end

	def self.start(work_day, user_id)
		if work_day.status != "Started"
			work_day.start_time = Time.now
			work_day.user_id = user_id
			work_day.status="Started"
			work_day.save
		end
	end

	def self.finish(work_day)
		if work_day.status != "Finished"
      work_day.end_time = Time.now
      work_day.status = "Finished"
      work_day.save
      WorkDay.pause_all_tasks(work_day.user_id)
		end
	end

	def self.get_work_day(user_id)
		@work_day = WorkDay.where(:user_id => user_id).order(:end_time => 'desc').first
		if @work_day
			if @work_day.status == "Started"
				@work_day
			else
				end_time = @work_day.end_time
				next_day = end_time + 1.day
				next_start_time = Time.new(next_day.year, next_day.month, next_day.day, 0, 0, 0)
				if Time.now >= next_start_time
					WorkDay.new
				else
					nil
				end
			end
		else
			WorkDay.new
		end
	end

end