class CreateAdvancedSearches < ActiveRecord::Migration[5.1]
  def change
    create_table :advanced_searches do |t|
      t.string :keywords
      t.integer :project_id
      t.string :type
      t.date :date_added
      t.string :status
      t.integer :assigned_user_id

      t.timestamps
    end
  end
end
