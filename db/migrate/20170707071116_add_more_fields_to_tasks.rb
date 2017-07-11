class AddMoreFieldsToTasks < ActiveRecord::Migration[5.1]
  def change
  	add_column :tasks, :assigned_user, :integer
    add_column :tasks, :type, :string
    add_column :tasks, :intervals, :text
    add_column :tasks, :status, :string
  end
end
