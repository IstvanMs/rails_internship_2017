class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.references :commenter, foreign_key: true
      t.text :text
      t.references :reply_to, foreign_key: true

      t.timestamps
    end
  end
end
