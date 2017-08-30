class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.references :subscription, foreign_key: true
      t.integer :amount

      t.timestamps
    end
  end
end
