class RemoveTypeFromAdvancedSearch < ActiveRecord::Migration[5.1]
  def change
    remove_column :advanced_searches, :type, :string
  end
end
