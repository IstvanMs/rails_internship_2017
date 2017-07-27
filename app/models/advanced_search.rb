class AdvancedSearch < ApplicationRecord

  def taasks
    @taasks ||= find_taasks
  end

  private

  def find_taasks
    taasks = Taask.order(:title)
    taasks = taasks.where("title like ?", "%#{keywords}%") if keywords.present?
    taasks = taasks.where(project_id: project_id) if project_id.present?
    taasks = taasks.where(assigned_user_id: assigned_user_id) if assigned_user_id.present?

    # RESTUUUUL

  end
end