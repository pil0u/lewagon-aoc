# frozen_string_literal: true

module Aoc
  def self.fetch_json(event_year, id, session_cookie)
    Rails.logger.info "Fetching data from leaderboard #{id}..."
    url = URI("https://adventofcode.com/#{event_year}/leaderboard/private/view/#{id}.json")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Cookie"] = "session=#{session_cookie}"
    response = https.request(request)
    Rails.logger.info "#{response.code} #{response.message}"

    JSON.parse(response.body)
  end

  def self.to_completions_array(members)
    Rails.logger.info "  Transforming JSON to match the completions table format..."

    user_aoc_ids = User.pluck(:aoc_id, :id).to_h.except(nil)
    now = Time.now.utc
    completions = []

    members.each do |member_id, results|
      next unless (user_id = user_aoc_ids[member_id.to_i])

      results["completion_day_level"].each do |day, challenges|
        challenges.each do |challenge, value|
          completion = {
            user_id:,
            day: day.to_i,
            challenge: challenge.to_i,
            completion_unix_time: value["get_star_ts"],
            updated_at: now
          }

          completions << completion
        end
      end
    end

    completions
  end

  def self.in_progress?
    now = Time.now.getlocal("-05:00")

    now >= start_time && now < end_time
  end

  def self.next_puzzle_time_from(time)
    return start_time if time < start_time
    return start_time + 1.year if time >= end_time

    (time + 1.day).midnight
  end

  def self.start_time
    Time.new(2021, 12, 1, 0, 0, 0, "-05:00")
  end

  def self.end_time
    Time.new(2021, 12, 25, 0, 0, 0, "-05:00")
  end
end
