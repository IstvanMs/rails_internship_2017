class Role < ApplicationRecord
	belongs_to :company
	has_many :users
	has_many :roleFields, dependent: :destroy

	validates :role_name, :presence => true, :length => { :in => 3..20 }
end
