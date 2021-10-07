# frozen_string_literal: true

module Aoc
  def self.fetch_json(id)
    Rails.logger.info "Fetching data from leaderboard #{id}"
    url = URI("https://adventofcode.com/2021/leaderboard/private/view/#{id}.json")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Cookie"] = "session=#{ENV['SESSION_COOKIE']}"
    response = https.request(request)
    Rails.logger.info "#{response.code} #{response.message}"

    JSON.parse(response.body)
  end
end
