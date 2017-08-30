class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.references :company, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
