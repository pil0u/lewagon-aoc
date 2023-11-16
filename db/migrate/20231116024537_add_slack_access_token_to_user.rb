class AddSlackAccessTokenToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :slack_access_token, :string
  end
end
