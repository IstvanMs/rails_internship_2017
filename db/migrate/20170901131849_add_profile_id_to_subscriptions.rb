class AddProfileIdToSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :subscriptions, :profile_id, :string
  end
end
