class ReportsController < ApplicationController
	before_action :authenticate_user, :only => [:index, :by_user, :by_project]

	def index
	end

	def by_user
	end

	def by_project
	end

end