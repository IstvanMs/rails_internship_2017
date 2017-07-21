class AddStatusToWorkDay < ActiveRecord::Migration[5.1]
  def change
    add_column :work_days, :status, :string
  end
end
