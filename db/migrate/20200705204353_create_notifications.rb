class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.references :target, polymorphic: true
      t.boolean :read, null: false, default: false
      t.references :user, null: false, foreign_key: true
      t.text :message, null: false

      t.timestamps
    end
  end
end
