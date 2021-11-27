class CreateCityPointsView < ActiveRecord::Migration[6.1]
  def change
    create_view :city_points, materialized: true
    add_index :city_points, [:batch_id, :day, :challenge], unique: true
  end
end
