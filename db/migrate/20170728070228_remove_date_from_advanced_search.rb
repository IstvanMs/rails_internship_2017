class RemoveDateFromAdvancedSearch < ActiveRecord::Migration[5.1]
  def change
    remove_column :advanced_searches, :date_added, :date
  end
end
