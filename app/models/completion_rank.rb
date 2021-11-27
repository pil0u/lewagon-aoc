class CompletionRank < ApplicationRecord
  belongs_to :completion

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: true)
  end
end
