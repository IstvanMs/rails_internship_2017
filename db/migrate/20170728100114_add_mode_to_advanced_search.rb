class AddModeToAdvancedSearch < ActiveRecord::Migration[5.1]
  def change
    add_column :advanced_searches, :mode, :string
  end
end
