class AddCollaboratorsToRepo < ActiveRecord::Migration[5.0]
  def change
    add_column :repos, :collaborators, :integer, array: true, default: []
  end
end
