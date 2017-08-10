class Note < ApplicationRecord

	belongs_to :company
	validates :text, presence: true,
	            length: { minimum: 6 }

	def self.get_notes(user)
		@company = Company.find(user.company_id)
		case user.role
			when 'Employee'
				@notes = Note.where(:visibility => 'general', :company_id => @company.id)
				@notes += Note.where(:visibility => ProjectUser.where(:user_id => user).collect{|p| 'project-' + p.project_id.to_s}, :company_id => @company.id)
				@notes += Note.where(:visibility => Task.where(:assigned_user => user).collect{|t| 'task-' + t.id.to_s}, :company_id => @company.id)
				@notes += Note.where(:visibility => 'user-'+ user.id.to_s, :company_id => @company.id)
		        @notes = @notes.sort_by{|n| n.visibility}
			when 'Admin'
				@notes = Note.where(:visibility => 'general', :company_id => @company.id)
				@notes += Note.where(:visibility => ProjectUser.where(:user_id => user).collect{|p| 'project-' + p.project_id.to_s}, :company_id => @company.id)
				@notes += Note.where(:visibility => Task.where(:assigned_user => user).collect{|t| 'task-' + t.id.to_s}, :company_id => @company.id)
				@notes += Note.where(:visibility => 'user-'+ user.id.to_s, :company_id => @company.id)
		        @notes = @notes.sort_by{|n| n.visibility}
			when 'Client'
				@table = Project.joins(:tasks , :projectUsers => :user ).where(:project_users => { :user_id => user})
				@notes = Note.where(:visibility => 'general', :company_id => @company.id)
				@notes += Note.where(:visibility => ProjectUser.where(:user_id => user).collect{|p| 'project-' + p.project_id.to_s}, :company_id => @company.id)
				@notes += Note.where(:visibility => @table.collect(&:task_ids).uniq.flatten.collect{|id| 'task-' + id.to_s})
				@notes += Note.where(:visibility => 'user-'+ user.id.to_s, :company_id => @company.id)
		        @notes = @notes.sort_by{|n| n.visibility}
			when 'Manager'
				@notes = Note.where(:company_id => @company.id)
				@notes = @notes.sort_by{|n| n.visibility}
			else
				puts 'Role error!'
		end
		return @notes
	end
end
