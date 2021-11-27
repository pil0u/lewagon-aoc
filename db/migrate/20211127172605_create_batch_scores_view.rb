class CreateBatchScoresView < ActiveRecord::Migration[6.1]
  def change
    create_view :batch_scores, materialized: true
    add_index :batch_scores, :batch_id, unique: true
  end
end
