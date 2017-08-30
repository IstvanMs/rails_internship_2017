class Subscription < ApplicationRecord
  belongs_to :company
  has_many :payments, dependent: :destroy
end
