class CreateProjectUsers < ActiveRecord::Migration[5.1]
	def change
    	create_table :projectUsers do |t|
      		t.belongs_to :user, foreign_key: true
      		t.belongs_to :project, foreign_key: true

	    	t.timestamps
    	end
    end 
end