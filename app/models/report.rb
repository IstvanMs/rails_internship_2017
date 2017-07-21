class Report
	def self.generate_data(current_filter)
		@data = Array.new(Time.days_in_month(Date::MONTHNAMES.index(current_filter['month'])))
		for i in 1..@data.length
			@d = DateTime.parse(i.to_s + '-' + Date::MONTHNAMES.index(current_filter['month']).to_s + '-' + current_filter['year'].to_s)
			@d2 = DateTime.parse(i.to_s + '-' + Date::MONTHNAMES.index(current_filter['month']).to_s + '-' + current_filter['year'].to_s + ' 23:59:59')
			if i<= Time.now.day 
				@tasks = Task.where('assigned_user = ? and ((started_at < ? and finished_at > ?) or (started_at < ? and finished_at is ?) or (started_at > ? and started_at <= ?))', current_filter['user'].id, @d, @d, @d, nil, @d, @d2)
				@task_infos = Task.get_report_task_infos(@tasks, @d, @d2)
				@data[i] = {'day' => i, 'tasks' => @tasks, 'task_infos' => @task_infos}
			else
				@data[i] = {'day' => i, 'tasks' => '', 'task_infos' => ''}
			end
		end
		return @data
	end

	def self.generate_data_project(current_filter)
		@tasks = Project.find(current_filter['project'].id).tasks

		@d = DateTime.parse(current_filter['day'])
		@d2 = DateTime.parse(current_filter['day'] + ' 23:59:59')
		@task_infos = Task.get_report_task_infos(@tasks, @d, @d2)
		@data = {'tasks' => @tasks, 'task_infos' => @task_infos}

		return @data

	end
end
