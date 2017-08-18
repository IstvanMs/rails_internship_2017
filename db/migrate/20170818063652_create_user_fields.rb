class CreateUserFields < ActiveRecord::Migration[5.1]
  def change
    create_table :user_fields do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
