class RoleField < ApplicationRecord
  belongs_to :role

  validates :name, :presence => true
  validates :field_type, :presence => true
  validates :role_id, :presence => true
  validate :check_if_exists, :on => :create

  def check_if_exists
  	if RoleField.exists?(:name => name, :role_id => role_id)
		  errors.add(:name, 'Role field name has already been taken')
  	end
  end
end
