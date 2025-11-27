# frozen_string_literal: true

class Aoc
  class << self
    def year
      2025
    end

    def event_timezone
      Time.find_zone!("America/New_York")
    end

    def pilou_timezone
      Time.find_zone!("Europe/Paris")
    end

    # Official event related times and helpers

    def begin_time
      Time.new(year, 12, 1, 0, 0, 0, event_timezone)
    end

    def end_time
      Time.new(year, 12, 12, 23, 59, 59, event_timezone)
    end

    def in_progress?
      now = event_timezone.now

      now >= begin_time && now < end_time
    end

    def latest_day
      now = event_timezone.now

      return 0 if now < begin_time
      return 12 if now > end_time

      now.day
    end

    def next_puzzle_time
      now = event_timezone.now

      return begin_time if now < begin_time
      return begin_time + 1.year if now >= end_time

      (now + 1.day).midnight
    end

    def release_time(day)
      Time.new(year, 12, day, 0, 0, 0, event_timezone)
    end

    def url(day)
      "https://adventofcode.com/#{year}/day/#{day}"
    end

    # Le Wagon specific times and helpers

    def lewagon_launch_time
      Time.new(year, 11, 19, 8, 30, 0, pilou_timezone)
    end

    def lewagon_lock_time
      Time.new(year, 12, 8, 17, 30, 0, pilou_timezone)
    end

    def lewagon_end_time
      Time.new(year, 12, 31, 11, 30, 0, pilou_timezone)
    end

    def private_leaderboards
      ENV.fetch("AOC_ROOMS").split(",")
    end

    def slack_channel
      "https://lewagon-alumni.slack.com/archives/C02PN711H09"
    end
  end
end
