class CityContribution < ApplicationRecord
  belongs_to :completion

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end
end
