class AddTitleToRebase < ActiveRecord::Migration[5.0]
  def change
    add_column :rebases, :title, :string
  end
end
