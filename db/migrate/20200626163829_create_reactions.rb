class CreateReactions < ActiveRecord::Migration[6.0]
  def change
    create_table :reactions do |t|
      t.integer :sentiment, default: 0, null: false
      t.references :user
      t.references :content, polymorphic: true

      t.timestamps
    end
  end
end
