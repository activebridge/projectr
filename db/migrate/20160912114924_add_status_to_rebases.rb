class AddStatusToRebases < ActiveRecord::Migration[5.0]
  def change
    add_column :rebases, :status, :string
  end
end
