# frozen_string_literal: true

class CityContribution < ApplicationRecord
  belongs_to :city
  belongs_to :user
  belongs_to :completion

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end
end
