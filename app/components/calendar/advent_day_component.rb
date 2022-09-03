# frozen_string_literal: true

module Calendar
  class AdventDayComponent < ApplicationComponent
    def initialize(advent_day:, now:)
      @advent_day = advent_day
      @now = now

      @day_number = @advent_day[:release_time].day

      set_colour
      set_wiggle
    end

    private

    def set_colour
      unlocked = @now >= @advent_day[:release_time]

      @colour = if unlocked
                  case @advent_day[:parts_solved]
                  when 0 then "text-aoc-gray-dark"
                  when 1 then "text-aoc-silver"
                  when 2 then "text-aoc-gold"
                  end
                else
                  "text-aoc-gray-darker"
                end
    end

    def set_wiggle
      @wiggle = Aoc.in_progress? && @day_number == @now.day
    end
  end
end
