# frozen_string_literal: true

module Aoc
  def self.fetch_json(id)
    Rails.logger.info "Fetching data from leaderboard #{id}..."
    url = URI("https://adventofcode.com/2021/leaderboard/private/view/#{id}.json")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Cookie"] = "session=#{ENV['SESSION_COOKIE']}"
    response = https.request(request)
    Rails.logger.info "#{response.code} #{response.message}"

    JSON.parse(response.body)
  end

  def self.to_scores_array(json)
    Rails.logger.info "  Transforming JSON to match the scores table format..."

    user_aoc_ids = User.pluck(:aoc_id, :id).to_h.except(nil)
    now = Time.now.utc
    scores = []

    json["members"].each do |member_id, results|
      next unless (user_id = user_aoc_ids[member_id.to_i])

      results["completion_day_level"].each do |day, challenges|
        challenges.each do |challenge, value|
          score = {
            user_id: user_id,
            day: day.to_i,
            challenge: challenge.to_i,
            completion_unix_time: value["get_star_ts"],
            created_at: now,
            updated_at: now
          }

          scores << score
        end
      end
    end

    scores
  end
end
