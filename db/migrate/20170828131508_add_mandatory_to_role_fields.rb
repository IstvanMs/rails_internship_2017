class AddMandatoryToRoleFields < ActiveRecord::Migration[5.1]
  def change
    add_column :role_fields, :mandatory, :boolean
  end
end
