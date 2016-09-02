class AddAutoRebaseToRepo < ActiveRecord::Migration[5.0]
  def change
    add_column :repos, :auto_rebase, :boolean, default: false
  end
end
