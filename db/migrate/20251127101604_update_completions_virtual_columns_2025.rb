# frozen_string_literal: true

class UpdateCompletionsVirtualColumns2025 < ActiveRecord::Migration[7.2]
  BEGINNING_OF_EXERCISES = ActiveSupport::TimeZone["EST"].local(2025, 12, 1, 0, 0, 0).freeze
  INTERVAL_BETWEEN_EXERCISES = 1.day

  def change
    safety_assured do
      release_date_sql = ActiveRecord::Base.sanitize_sql_array(
        ["to_timestamp(?::double precision + (day - 1) * ?)",
         BEGINNING_OF_EXERCISES.to_i,
         INTERVAL_BETWEEN_EXERCISES.to_i]
      )

      remove_column :completions, :release_date, :timestamp
      remove_column :completions, :duration, :interval

      add_column :completions, :release_date, :virtual, type: :timestamp, stored: true, as: release_date_sql
      add_column :completions, :duration,     :virtual, type: :interval, stored: true,
                                                        as: <<~SQL.squish
                                                          CASE
                                                            WHEN completion_unix_time IS NOT NULL
                                                              THEN to_timestamp(completion_unix_time::double precision) - #{release_date_sql}
                                                            ELSE NULL
                                                          END
                                                        SQL
    end
  end
end
