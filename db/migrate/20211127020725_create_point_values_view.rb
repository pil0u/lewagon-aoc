class CreatePointValuesView < ActiveRecord::Migration[6.1]
  def change
    create_view :point_values, materialized: true
    add_index :point_values, :completion_id, unique: true
  end
end
