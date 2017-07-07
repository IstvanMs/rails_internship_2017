class DashboardsController < ApplicationController	
  before_action :authenticate_user, :only => [:index]

  def index
  	case @current_user.role
      when "Admin"
        render '/layouts/_index_admin'
      when 'Employee'
        render '/layouts/_index_employee'
      when 'Manager'
        render '/layouts/_index_manager'
      when 'Client'
        render '/layouts/_index_client'
      else puts 'Role error!'
      end
  end
end
