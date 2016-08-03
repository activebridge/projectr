class CreateRepos < ActiveRecord::Migration[5.0]
  def change
    create_table :repos do |t|
      t.references :user, foreign_key: true
      t.string :name, index: true
      t.string :ssh

      t.timestamps
    end
  end
end
