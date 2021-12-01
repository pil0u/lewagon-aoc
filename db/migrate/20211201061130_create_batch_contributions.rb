class CreateBatchContributions < ActiveRecord::Migration[6.1]
  def change
    create_view :batch_contributions, materialized: true
    add_index :batch_contributions, :completion_id, unique: true
  end
end
