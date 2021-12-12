class UserPoint < ApplicationRecord
  belongs_to :user
  belongs_to :completion

  scope :completed, -> { where(completed: true) }

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: true)
  end
end
