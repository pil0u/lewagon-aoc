# frozen_string_literal: true

module ApplicationHelper

### old

  def publication_time(day)
    Time.new(ENV.fetch("EVENT_YEAR").to_i, 12, day, 0, 0, 0, "-05:00")
  end

  def duration_as_chrono(date, since:)
    date = Time.zone.at(date) if date.is_a?(String) || date.is_a?(Numeric)
    duration = ActiveSupport::Duration.build(date - since)
    if duration < 1.day
      parts = duration.parts
      [parts[:hours] || 0, parts[:minutes] || 0, parts[:seconds] || 0].map { |n| n.to_i.to_s.rjust(2, "0") }.join(":")
    else
      ">24h"
    end
  end
end
