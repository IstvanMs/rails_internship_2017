class AddFromAndToToAdvancedSearch < ActiveRecord::Migration[5.1]
  def change
    add_column :advanced_searches, :from, :date
    add_column :advanced_searches, :to, :date
  end
end
