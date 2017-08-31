class AddTransIdToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :transID, :string
  end
end
