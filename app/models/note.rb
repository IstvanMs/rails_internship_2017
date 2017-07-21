class Note < ApplicationRecord

	validates :text, presence: true,
	            length: { minimum: 6 }

	def self.get_notes(user)
		case user.role
			when 'Employee'
				@table = Project.joins(:tasks).where(:tasks => { :assigned_user => user}).uniq
				@notes = Note.where(:visibility => 'general')
				@notes += Note.where(:visibility => @table.collect{|p| 'project-' + p.id.to_s})
				@notes += Note.where(:visibility => @table.collect(&:task_ids).uniq.flatten.collect{|id| 'task-' + id.to_s})
				@notes += Note.where(:visibility => 'user-'+ user.id.to_s)
		        @notes = @notes.sort_by{|n| n.visibility}
			when 'Admin'
				@table = Project.joins(:tasks).where(:tasks => { :assigned_user => user}).uniq
				@notes = Note.where(:visibility => 'general')
				@notes += Note.where(:visibility => @table.collect{|p| 'project-' + p.id.to_s})
				@notes += Note.where(:visibility => @table.collect(&:task_ids).uniq.flatten.collect{|id| 'task-' + id.to_s})
				@notes += Note.where(:visibility => 'user-'+ user.id.to_s)
		        @notes = @notes.sort_by{|n| n.visibility}
			when 'Client'
				@table = Project.joins(:tasks , :projectUsers => :user ).where(:project_users => { :user_id => user})
				@notes = Note.where(:visibility => 'general')
				@notes += Note.where(:visibility => @table.collect{|p| 'project-'+p.id.to_s})
				@notes += Note.where(:visibility => @table.collect(&:task_ids).uniq.flatten.collect{|id| 'task-' + id.to_s})
				@notes += Note.where(:visibility => 'user-'+ user.id.to_s)
		        @notes = @notes.sort_by{|n| n.visibility}
			when 'Manager'
				@notes = Note.all
				@notes = @notes.sort_by{|n| n.visibility}
			else
				puts 'Role error!'
		end
		return @notes
	end
end
