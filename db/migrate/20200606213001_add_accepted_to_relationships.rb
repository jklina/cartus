class AddAcceptedToRelationships < ActiveRecord::Migration[6.0]
  def change
    add_column :relationships, :accepted, :boolean, null: false, default: false
  end
end
