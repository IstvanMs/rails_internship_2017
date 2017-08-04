class AdvancedSearch < ApplicationRecord

  def self.tasks_filter(advanced_search_id)
    @adv_search = AdvancedSearch.where( :id => advanced_search_id )
    @tasks = find_tasks(@adv_search)
  end

  private

  def self.find_tasks(adv_search)
    tasks = Task.order(:title)
    tasks = tasks.where("title like ?", "%#{keywords}%") if keywords.present?
    tasks = tasks.where(project_id: project_id) if project_id.present?
    tasks = tasks.where(assigned_user_id: assigned_user_id) if assigned_user_id.present?
    #status
    #mode
    tasks = tasks.where("interval >= ?", from) if from.present?
    tasks = tasks.where("interval <= ?", to) if to.present?
  end

end