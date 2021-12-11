class UserPoint < ApplicationRecord
  belongs_to :user
  belongs_to :completion_id

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: true)
  end
end
