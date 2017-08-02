class Comment < ApplicationRecord
  validates :text, :presence => true, :length => { :minimum => 1 }

  belongs_to :user
  belongs_to :task
end
