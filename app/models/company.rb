class Company < ApplicationRecord

  has_many :users
  has_many :projects
  has_many :notes

  def self.get_admins
    User.where :role => "Admin"
  end

end
