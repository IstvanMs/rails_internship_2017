class Company < ApplicationRecord

  has_many :users, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  def self.get_admins(company_id)
    User.where( :role => "Admin", :company_id => company_id )
  end

end
