class Project < ApplicationRecord
	has_many :projectUsers, dependent: :destroy
	has_many :users, through: :projectUsers


	has_many :tasks, dependent: :destroy

	validates :title, presence: true,
                    length: { minimum: 5 }

    def self.create_project_infos(projects)
	    @project_infos = Hash.new
	    projects.each do |p|
	      @project_infos[p.id] = {'client_name' => ProjectUser.find_by(:project => p).user.username,'created_at' => p.created_at.strftime("%F %I:%M%p")}
	      @tasks = Task.where(:project => p.id)
	      @duration = 0
	      @tasks.each do |t|
	        @intervals = JSON.parse(t.intervals)
	        @time = 0
	        @intervals.each do |i|
	          if i['start_time'] != nil && i['end_time'] != nil
	            @time += (Time.parse(i['end_time']) - Time.parse(i['start_time']))/60
	          end
	        end
	        if @time != 0
	          @time = @time.truncate + 1
	        end
	        @duration += @time
	      end
	      @project_infos[p.id] = {'client_name' => ProjectUser.find_by(:project => p).user.username,'created_at' => p.created_at.strftime("%F %I:%M%p"),'duration' => @duration}
	    end
	    return @project_infos
  	end
end
