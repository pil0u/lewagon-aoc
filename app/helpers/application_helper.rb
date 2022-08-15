# frozen_string_literal: true

require "aoc"

module ApplicationHelper
  def day_css(now, advent_day)
    unlocked = now >= Aoc.start_time && advent_day <= now

    # TODO: eager load all scores
    parts_solved = Completion.where(user: current_user, day: advent_day.day).count

    {
      "text-aoc-gray-darker": !unlocked,
      "text-aoc-gray-dark": unlocked && parts_solved == 0,
      "text-aoc-silver": unlocked && parts_solved == 1,
      "text-aoc-gold": unlocked && parts_solved == 2
    }
  end

  def ranking_css(rank, rank_col: false)
    {
      "text-gold": rank == 1,
      "text-aoc-silver text-shadow-silver": rank == 2,
      "text-aoc-bronze text-shadow-bronze": rank == 3,
      "text-xl": rank <= 3 && rank_col,
      strong: rank > 3 && rank_col
    }
  end

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

  def contributor_ids
    User::CONTRIBUTORS
  end
end
