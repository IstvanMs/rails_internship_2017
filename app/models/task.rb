class Task < ApplicationRecord
  belongs_to :project

  def tasks
  	belongs_to :users, :foreign_key => 'assigned_user'
  end
end
