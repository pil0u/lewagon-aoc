# frozen_string_literal: true

class Aoc
  def self.event_timezone
    Time.find_zone!("America/New_York")
  end

  def self.pilou_timezone
    Time.find_zone!("Europe/Paris")
  end

  # Official event related times and helpers

  def self.begin_time
    Time.new(2023, 12, 1, 0, 0, 0, event_timezone)
  end

  def self.end_time
    Time.new(2023, 12, 25, 23, 59, 59, event_timezone)
  end

  def self.in_progress?
    now = event_timezone.now

    now >= begin_time && now < end_time
  end

  def self.latest_day
    now = event_timezone.now

    return 0 if now < begin_time
    return 25 if now > end_time

    now.day
  end

  def self.next_puzzle_time
    now = event_timezone.now

    return begin_time if now < begin_time
    return begin_time + 1.year if now >= end_time

    (now + 1.day).midnight
  end

  def self.release_time(day)
    Time.new(2023, 12, day, 0, 0, 0, event_timezone)
  end

  def self.url(day)
    "https://adventofcode.com/2023/day/#{day}"
  end

  # Le Wagon specific times and helpers

  def self.lewagon_launch_time
    Time.new(2023, 11, 17, 8, 30, 0, pilou_timezone)
  end

  def self.lewagon_lock_time
    Time.new(2023, 12, 8, 17, 30, 0, pilou_timezone)
  end

  def self.lewagon_end_time
    Time.new(2023, 12, 31, 11, 30, 0, pilou_timezone)
  end

  def self.private_leaderboards
    ENV.fetch("AOC_ROOMS").split(",")
  end

  def self.slack_channel
    "https://lewagon-alumni.slack.com/archives/C02PN711H09"
  end
end
