# frozen_string_literal: true

class Aoc
  def self.begin_time
    Time.new(2022, 12, 1, 0, 0, 0, "-05:00")
  end

  def self.end_time
    Time.new(2022, 12, 31, 11, 30, 0, "UTC")
  end

  def self.in_progress?
    now = Time.now.getlocal("-05:00")

    now >= begin_time && now < end_time
  end

  def self.lock_time
    Time.new(2022, 12, 8, 11, 30, 0, "UTC")
  end

  def self.next_puzzle_time
    now = Time.now.getlocal("-05:00")

    return begin_time if now < begin_time
    return begin_time + 1.year if now >= end_time

    (now + 1.day).midnight
  end

  def self.slack_channel
    "slack://channel?team=T02NE0241&id=C02PN711H09"
  end

  # old

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
end
