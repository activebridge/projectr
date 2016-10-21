class AddChannelUrlToRepos < ActiveRecord::Migration[5.0]
  def change
    add_column :repos, :channel_url, :string
  end
end
