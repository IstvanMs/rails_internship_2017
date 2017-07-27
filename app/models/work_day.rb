class WorkDay < ApplicationRecord

	belongs_to :user

	def self.start(work_day)
		puts '_'
		puts work_day
		puts '_'
		if work_day.status != "Started"
				work_day.start_time = Time.now
		end
			work_day.update_attribute(:status, 'Started')
	end

	def self.finish(work_day)
		if work_day.status != "Finished"
				work_day.end_time = Time.now
		end
			work_day.update_attribute(:status, 'Finished')
	end

	def self.get_work_day
		if WorkDay.exists?(:status => "Started")
			return WorkDay.find_by(:status => 'Started')
		else
			return WorkDay.new
		end
	end

	end