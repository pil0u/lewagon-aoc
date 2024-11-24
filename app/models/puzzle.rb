# frozen_string_literal: true

class Puzzle < ApplicationRecord
  validate :date_during_aoc

  DIFFICULTY_LEVELS = {
    1 => { difficulty: "EASY", colour: "🟢" },
    2 => { difficulty: "HARD", colour: "🟡" },
    3 => { difficulty: "VERY HARD", colour: "🟠" },
    4 => { difficulty: "HARDCORE", colour: "🔴" },
    5 => { difficulty: "IMPOSSIBLE", colour: "⚫" }
  }.freeze

  DEFAULT_DIFFICULTY = { difficulty: "UNKNOWN", colour: "⚪" }.freeze

  def url
    Aoc.url(date.day)
  end

  private

  def date_during_aoc
    errors.add(:date, "must be during AoC") unless date.in? Aoc.begin_time.to_date..Aoc.end_time.to_date
  end

  class << self
    def by_date(date)
      find_by(date:)
    end
  end
end
