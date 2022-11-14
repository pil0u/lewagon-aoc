# frozen_string_literal: true

module ApplicationHelper
  def duration_as_text(duration)
    return "-" if duration.nil?

    if duration < 48.hours
      parts = duration.parts
      [parts[:hours] || 0, parts[:minutes] || 0, parts[:seconds] || 0].map { |n| n.to_i.to_s.rjust(2, "0") }.join(":")
    else
      ">48h"
    end
  end
end
