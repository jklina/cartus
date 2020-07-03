class AddConfirmedAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :email_confirmation_token, :string, null: false, default: ""
    add_column :users, :email_confirmed_at, :datetime
    User.all.update_all(email_confirmed_at: Date.today)
  end
end
