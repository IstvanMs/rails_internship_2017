class AdvancedSearch < ApplicationRecord

  def self.tasks_filter(advanced_search_id, user_id)
    @adv_search = AdvancedSearch.find (advanced_search_id )
    @tasks = AdvancedSearch.find_tasks(@adv_search, user_id)
  end

  private

  def self.find_tasks(adv_search, user_id)
    @user = User.find(user_id)

    if @user.role == 'Manager'

      tasks = Task.all.order(status: :desc, title: :asc)

    else

      if @user.role != 'Client'

        tasks= Task.where(:assigned_user => @user.id).order(status: :desc, title: :asc)

      else

        tasks= Task.where(:project => ProjectUser.joins(:user).where(:user => @user).collect(&:project_id)).order(status: :desc, title: :asc)

      end
    end
    tasks = tasks.where("title like ?", "%#{adv_search.keywords}%") if adv_search.keywords.present?
    tasks = tasks.where(project_id: adv_search.project_id) if adv_search.project_id.present?
    tasks = tasks.where(assigned_user: adv_search.assigned_user_id) if adv_search.assigned_user_id.present?
    tasks = tasks.where(status: adv_search.status) if adv_search.status.present?
    tasks = tasks.where(task_type: adv_search.mode) if adv_search.mode.present?
    tasks = tasks.where("created_at >= ?", Time.new(adv_search.from.year, adv_search.from.day, adv_search.from.month,  0,  0,  0)) if adv_search.from.present?
    tasks = tasks.where("created_at <= ?", Time.new(adv_search.to.year, adv_search.to.day, adv_search.to.month,  23,  59,  59)) if adv_search.to.present?
    if tasks.length == Task.all.length 
      tasks = nil
    end
    return tasks
  end

end