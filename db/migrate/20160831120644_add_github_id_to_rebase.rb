class AddGithubIdToRebase < ActiveRecord::Migration[5.0]
  def change
    add_column :rebases, :github_id, :integer
  end
end
