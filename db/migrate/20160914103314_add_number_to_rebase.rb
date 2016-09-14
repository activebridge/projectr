class AddNumberToRebase < ActiveRecord::Migration[5.0]
  def change
    add_column :rebases, :number, :integer
  end
end
