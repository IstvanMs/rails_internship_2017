class CreateRoleFields < ActiveRecord::Migration[5.1]
  def change
    create_table :role_fields do |t|
      t.references :role, foreign_key: true
      t.string :name
      t.string :field_type
      t.text :values

      t.timestamps
    end
  end
end
