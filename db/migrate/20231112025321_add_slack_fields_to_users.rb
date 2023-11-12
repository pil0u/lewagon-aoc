class AddSlackFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :slack_id, :string
    add_column :users, :slack_username, :string
  end
end
