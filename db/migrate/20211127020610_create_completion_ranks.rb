class CreateCompletionRanks < ActiveRecord::Migration[6.1]
  def change
    create_view :completion_ranks, materialized: true
    add_index :completion_ranks, :completion_id, unique: true
    add_index :completion_ranks, :in_batch
  end
end
