class BatchScore < ApplicationRecord
  belongs_to :batch

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: true)
  end
end
