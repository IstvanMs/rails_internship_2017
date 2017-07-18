class AddDateFieldsToTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :started_at, :datetime
    add_column :tasks, :finished_at, :datetime
    add_column :tasks, :time_worked, :integer
  end
end
