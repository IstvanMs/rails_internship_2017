class CreateRoles < ActiveRecord::Migration[5.1]
  def change
    create_table :roles do |t|
      t.string :role_name
      t.string :dashboard
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
