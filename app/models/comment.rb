class Comment < ApplicationRecord
  belongs_to :commenter
  belongs_to :reply_to
end
