class AddRememberTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :remember_token, :text
  end
end
