class CreateRanksView < ActiveRecord::Migration[6.1]
  def change
    create_view :ranks, materialized: true
    add_index :ranks, :user_id, unique: true
  end
end
