class CreateCityScoresView < ActiveRecord::Migration[6.1]
  def change
    create_view :city_scores, materialized: true
    add_index :city_scores, :city_id, unique: true
  end
end
