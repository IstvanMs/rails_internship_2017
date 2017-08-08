class Task < ApplicationRecord
  belongs_to :project
  validates :title, :presence => true, :uniqueness => true, :length => { :in => 1..20 }
  belongs_to :user, :foreign_key => 'assigned_user'
  has_many :comments, dependent: :destroy

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
      client_name = User.joins(:projects).where(:role => 'Client', :projects => {:id => t.project_id}).first
      @task_infos[t.id] = {'client_name' => client_name, 'assigned' => t.user,'last_update' => t.updated_at.strftime("%F %I:%M%p"),'duration' => @time,'project_name' => t.project.title}
    end
    return @task_infos
  end

  def self.get_report_task_infos(tasks, st_today, ed_today)
    @task_infos = Hash.new
    tasks.each do |t|
      @intervals = JSON.parse(t.intervals)
      @time = 0
      @time2 = 0
      @intervals.each do |i|
        if i['start_time'] != nil && i['end_time'] != nil
          ed_time = Time.parse(i['end_time'])
          st_time = Time.parse(i['start_time'])
          @time += (ed_time - st_time)/60
          if st_time >= st_today && st_time <= ed_today
            if ed_time <= ed_today
              @time2 += (ed_time - st_time)/60
            else
              @time2 += (ed_today - st_time)/60
            end
          end
        end
      end

      @task_infos[t.id] = {'duration' => @time, 'assigned' => t.user, 'duration_day' => @time2, 'project_name' => t.project.title}
    end
    return @task_infos
  end

  def self.generate_gant_data(tasks, st_today, ed_today)
    @gant_data = Hash.new 
    tasks.each do |t|
      @intervals = JSON.parse(t.intervals)
      @times = Hash.new
      j = 0
      @intervals.each do |i|
        if i['start_time'] != nil && i['end_time'] != nil
          ed_time = Time.parse(i['end_time'])
          st_time = Time.parse(i['start_time'])
          if st_time >= st_today && st_time <= ed_today
            if ed_time <= ed_today
              @time = ed_time
            else
              @time = ed_today
            end
            if @time != nil
              @times[j] = {'start' => st_time.strftime('%H:%M:%S'), 'end' => @time.strftime('%H:%M:%S'), 'start_pixel' => (st_time - st_today)/120, 'end_pixel' => (@time -st_today)/120}
              j += 1
            end
          end
        end
      end
      @gant_data[t.id] = {'intervals' => @times, 'nr_int' => @times.length}
    end
    return @gant_data
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
