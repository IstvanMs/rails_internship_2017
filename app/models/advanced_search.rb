class AdvancedSearch < ApplicationRecord

  def tasks
    @tasks ||= find_tasks
  end

  private

  def find_tasks
    tasks = Task.order(:title)
    tasks = tasks.where("title like ?", "%#{keywords}%") if keywords.present?
    tasks = tasks.where(project_id: project_id) if project_id.present?
    tasks = tasks.where(assigned_user_id: assigned_user_id) if assigned_user_id.present?
    tasks = tasks.where("interval >= ?", from) if from.present?
    tasks = tasks.where("interval <= ?", to) if to.present?
  end

end