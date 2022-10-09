# frozen_string_literal: true

# Parent for SQL view-backed models — see also [Scenic](https://github.com/scenic-views/scenic/)
class ApplicationView < ApplicationRecord
  self.abstract_class = true

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: true)
  end
end
