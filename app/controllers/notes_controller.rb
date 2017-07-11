class NotesController < ApplicationController
	before_action :manager_user, :only => [:new, :create, :destroy]
end
