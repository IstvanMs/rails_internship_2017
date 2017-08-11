class Role < ApplicationRecord
	belongs_to :company
	has_many :users

	validates :role_name, :presence => true, :length => { :in => 3..20 }
end
