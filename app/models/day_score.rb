# frozen_string_literal: true

class DayScore < ApplicationRecord
  belongs_to :user
  belongs_to :batch
  belongs_to :city
  belongs_to :first_completion, class_name: 'Completion'
  belongs_to :second_completion, class_name: 'Completion'

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: true)
  end
end
