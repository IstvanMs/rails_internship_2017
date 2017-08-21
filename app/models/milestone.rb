class Milestone < ApplicationRecord
	belongs_to :project
	has_many :tasks

	def self.milestone_infos(milestones)
		@milestones_infos = Hash.new
		milestones.each do |milestone|
			@milestones_infos[milestone.id] = {:tasks => Task.where(:milestone_id => milestone.id)}
		end
		return @milestones_infos
	end
end
