class CreateRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :relationships do |t|
      t.references :related, foreign_key: {to_table: :users}
      t.references :relatee, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end
