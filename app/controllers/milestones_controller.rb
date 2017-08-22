class MilestonesController < ApplicationController
	before_action :manager_user, :only => [:create, :destroy, :edit]
	before_action :authenticate_user

	def update
		@milestone = Milestone.find(params[:id])
		task_ids = JSON.parse(params[:task_ids])

		if @milestone.update(milestone_params)
			tasks = Task.where(:milestone_id => params[:id])
			tasks.each do |t|
				t.update_attribute(:milestone_id, nil) 
			end
			task_ids.each do |t|
				task = Task.find(t)
				task.update_attribute(:milestone_id, @milestone.id) 
			end
			flash[:notice] = "Updated!"
			flash[:color] = "valid"
		else
			flash[:notice] = "Error is update!"
			flash[:color] = "invalid"
		end
		redirect_to project_path(@milestone.project_id)
	end

	def edit
		@milestone = Milestone.find(params[:id])
		@project = Project.find(@milestone.project_id)
		@ids = Task.where(:milestone_id => params[:id]).collect{|t| t.id}.to_s
		puts @ids
		@tasks = Task.where(:project_id => @project.id)
	end

	def create
		@milestone = Milestone.new(milestone_params)
		task_ids = JSON.parse(params[:task_ids])
		
		if @milestone.save
			task_ids.each do |t|
				task = Task.find(t)
				task.update_attribute(:milestone_id, @milestone.id) 
			end
			flash[:notice] = "Saved!"
			flash[:color] = "valid"
		else
			flash[:notice] = "Error is save!"
			flash[:color] = "invalid"
		end
		redirect_to project_path(@milestone.project_id)
	end

	def destroy
		@milestone = Milestone.find(params[:id])

		if @milestone.destroy
			tasks = Task.where(:milestone_id => params[:id])
			tasks.each do |t|
				t.update_attribute(:milestone_id, nil) 
			end
			flash[:notice] = "Destroyed!"
			flash[:color] = "valid"
		else
			flash[:notice] = "Error is destroy!"
			flash[:color] = "invalid"
		end
		redirect_to project_path(@milestone.project_id)
	end

	private 
		def milestone_params
			params.require(:milestone).permit(:name, :due_date, :project_id)
		end
end
