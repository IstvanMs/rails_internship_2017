class Task < ApplicationRecord
  belongs_to :project
  validates :title, :presence => true, :uniqueness => true, :length => { :in => 1..20 }
  belongs_to :user, :foreign_key => 'assigned_user'

  def self.create_task_infos(tasks)
    @task_infos = Hash.new
    tasks.each do |t|
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

      @task_infos[t.id] = {'client_name' => ProjectUser.find_by(:project => t.project).user.username,'assigned' => User.find(t.assigned_user).username,'last_update' => t.updated_at.strftime("%F %I:%M%p"),'duration' => @time,'project_name' => Project.find(t.project.id).title}
    end
    return @task_infos
  end

  def self.start(task)
    if task.status != "Started"
      if task.status == 'Not-started'
        task.started_at = Time.now
      end
      @intervals = JSON.parse(task.intervals)
      @intervals.push(start_time: Time.now, end_time: nil)
      task.intervals = JSON.generate(@intervals)
      task.status = "Started"
      task.save
    end
  end

  def self.pause(task)
    if task.status != "Paused"
      @intervals = JSON.parse(task.intervals)
      @intervals.last["end_time"] = Time.now
        task.intervals = JSON.generate(@intervals)
        task.status = "Paused"
        task.save
    end
  end

  def self.finish(task)
    if task.status != "Finished"
      task.finished_at = Time.now
      @intervals = JSON.parse(task.intervals)

      unless task.status == 'Paused'
        @intervals.last["end_time"] = Time.now
      end
      task.intervals = JSON.generate(@intervals)
      task.status = "Finished"
      task.save
    end
  end
end
