# frozen_string_literal: true

class Aoc
  def self.begin_time
    Time.new(2022, 12, 1, 0, 0, 0, "-05:00")
  end

  def self.end_time
    Time.new(2022, 12, 25, 23, 59, 59, "UTC")
  end

  def self.in_progress?
    now = Time.now.getlocal("-05:00")

    now >= begin_time && now < end_time
  end

  def self.latest_day
    now = Time.now.getlocal("-05:00")

    return 0 if now < begin_time
    return 25 if now > end_time

    now.day
  end

  def self.launch_time
    Time.new(2022, 11, 10, 11, 30, 0, "UTC")
  end

  def self.lewagon_end_time
    Time.new(2022, 12, 31, 11, 30, 0, "UTC")
  end

  def self.lock_time
    Time.new(2022, 12, 9, 17, 30, 0, "UTC")
  end

  def self.next_puzzle_time
    now = Time.now.getlocal("-05:00")

    return begin_time if now < begin_time
    return begin_time + 1.year if now >= end_time

    (now + 1.day).midnight
  end

  def self.private_leaderboards
    ENV.fetch("AOC_ROOMS").split(",")
  end

  def self.slack_channel
    "slack://channel?team=T02NE0241&id=C02PN711H09"
  end

  def self.url(day)
    "https://adventofcode.com/2022/day/#{day}"
  end
end
