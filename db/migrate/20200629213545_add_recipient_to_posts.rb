class AddRecipientToPosts < ActiveRecord::Migration[6.0]
  def change
    add_reference :posts, :recipient, foreign_key: {to_table: :users}
  end
end
