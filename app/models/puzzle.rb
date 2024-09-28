# frozen_string_literal: true

class Puzzle < ApplicationRecord
  validate :date_during_aoc

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
