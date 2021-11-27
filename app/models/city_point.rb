# frozen_string_literal: true

class CityPoint < ApplicationRecord
  belongs_to :city

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: true)
  end
end
