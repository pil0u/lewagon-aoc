class CreateScoresView < ActiveRecord::Migration[6.1]
  def change
    create_view :scores, materialized: true
    add_index :scores, :user_id, unique: true
  end
end
