class Task < ApplicationRecord
  belongs_to :project
  validates :title, :presence => true, :uniqueness => true, :length => { :in => 1..20 }

  def tasks
  	belongs_to :users, :foreign_key => 'assigned_user'
  end
end
