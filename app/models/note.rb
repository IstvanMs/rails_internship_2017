class Note < ApplicationRecord

	validates :text, presence: true,
	            length: { minimum: 6 }

	def self.get_notes(user)
		case user.role
			when 'Employee'
				@notes = Note.where(:visibility => 'general')
		        @notes += Note.where(:visibility => Project.where(:id => Task.where(:assigned_user => user.id).collect{|t| t.project.id}).collect{|p| 'project-' + p.id.to_s})
		        @notes += Note.where(:visibility => Task.where(:assigned_user => user.id).collect{|t| 'task-' + t.id.to_s})
		        @notes += Note.where(:visibility => 'user-'+ user.id.to_s)
		        @notes = @notes.sort_by{|n| n.visibility}
			when 'Admin'
				@notes = Note.where(:visibility => 'general')
		        @notes += Note.where(:visibility => Project.where(:id => Task.where(:assigned_user => user.id).collect{|t| t.project.id}).collect{|p| 'project-' + p.id.to_s})
		        @notes += Note.where(:visibility => Task.where(:assigned_user => user.id).collect{|t| 'task-' + t.id.to_s})
		        @notes += Note.where(:visibility => 'user-'+ user.id.to_s)
		        @notes = @notes.sort_by{|n| n.visibility}
			when 'Client'
				@notes = Note.where(:visibility => 'general')
		        @notes += Note.where(:visibility => Project.where(:id => ProjectUser.where(:user => User.find(user.id)).collect{|pu| pu.project.id}).collect{|p| 'project-' + p.id.to_s})
		        @notes += Note.where(:visibility => Task.where(:project => Project.where(:id => ProjectUser.where(:user => User.find(user.id)).collect{|pu| pu.project.id}).collect{|p| p.id}).collect{|t| 'task-' + t.id.to_s})
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
