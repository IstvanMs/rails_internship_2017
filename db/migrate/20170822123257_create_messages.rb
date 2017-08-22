class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.integer :sender_id, :limit => 8
      t.integer :recipient_id, :limit => 8
      t.string :status
      t.string :subject
      t.text :content

      t.timestamps
    end
  end
end
