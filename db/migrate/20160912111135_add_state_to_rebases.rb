class AddStateToRebases < ActiveRecord::Migration[5.0]
  def change
    add_column :rebases, :state, :string
  end
end
