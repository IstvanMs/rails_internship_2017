class Company < ApplicationRecord

  has_many :users
  has_many :projects
  has_many :notes

  def self.get_admins(company_id)
    User.where( :role => "Admin", :company_id => company_id )
  end

end
