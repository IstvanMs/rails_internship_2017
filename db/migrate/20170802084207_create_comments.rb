class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.references :user, foreign_key: true
      t.text :text
      t.references :task, foreign_key: true
      t.integer :reply_to

      t.timestamps
    end
  end
end
