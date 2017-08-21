class CreateMilestones < ActiveRecord::Migration[5.1]
  def change
    create_table :milestones do |t|
      t.references :project, foreign_key: true
      t.string :name
      t.date :due_date

      t.timestamps
    end
  end
end
