class RoleField < ApplicationRecord
  belongs_to :role

  validates :name, :presence => true
  validates :field_type, :presence => true
  validates :role_id, :presence => true
end
