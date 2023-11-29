# frozen_string_literal: true

class Aoc
  def self.begin_time
    Time.new(2023, 12, 1, 0, 0, 0, Time.find_zone!("EST"))
  end

  def self.end_time
    Time.new(2023, 12, 25, 23, 59, 59, Time.find_zone!("EST"))
  end

  def self.in_progress?
    now = Time.now.utc

    now >= begin_time && now < end_time
  end

  def self.latest_day
    now = Time.now.utc

    return 0 if now < begin_time
    return 25 if now > end_time

    now.day
  end

  def self.lewagon_launch_time
    Time.new(2023, 11, 17, 8, 30, 0, Time.find_zone!("CET"))
  end

  def self.lewagon_lock_time
    Time.new(2023, 12, 8, 17, 30, 0, Time.find_zone!("CET"))
  end

  def self.lewagon_end_time
    Time.new(2023, 12, 31, 11, 30, 0, Time.find_zone!("CET"))
  end

  def self.next_puzzle_time
    now = Time.now.utc

    return begin_time if now < begin_time
    return begin_time + 1.year if now >= end_time

    (now + 1.day).midnight
  end

  def self.private_leaderboards
    ENV.fetch("AOC_ROOMS").split(",")
  end

  def self.slack_channel
    "https://lewagon-alumni.slack.com/archives/C02PN711H09"
  end

  def self.url(day)
    "https://adventofcode.com/2023/day/#{day}"
  end
end
