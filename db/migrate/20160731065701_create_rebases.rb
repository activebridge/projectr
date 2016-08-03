class CreateRebases < ActiveRecord::Migration[5.0]
  def change
    create_table :rebases do |t|
      t.references :user, foreign_key: true
      t.string :repo, index: true
      t.string :base
      t.string :head
      t.string :sha
      t.boolean :pushed, default: false

      t.timestamps
    end
  end
end
