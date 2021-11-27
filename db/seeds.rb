# frozen_string_literal: true

# Initialize unique state row
State.create!(
  {
    last_api_fetch_start: Time.at(0).utc,
    last_api_fetch_end: Time.at(0).utc
  }
)
Rails.logger.info "✔ States initialized"

# Initialize cities
cities = [
  "Amsterdam",
  "Bali",
  "Barcelona",
  "Belo Horizonte",
  "Berlin",
  "Bordeaux",
  "Brussels",
  "Buenos Aires",
  "Casablanca",
  "Cologne",
  "Dubai",
  "Istanbul",
  "Lausanne",
  "Lille",
  "Lima",
  "Lisbon",
  "London",
  "Lyon",
  "Madrid",
  "Marseille",
  "Mauritius",
  "Melbourne",
  "Mexico",
  "Milan",
  "Montreal",
  "Munich",
  "Nantes",
  "Nice",
  "Oslo",
  "Paris",
  "Rennes",
  "Rio de Janeiro",
  "Santiago",
  "Shanghai",
  "Shenzhen",
  "Singapore",
  "Stockholm",
  "São Paulo",
  "Tel Aviv",
  "Tokyo"
].map do |city|
  { name: city }
end

City.create!(cities)
Rails.logger.info "✔ Cities initialized"

# Initialize some users in development
if Rails.env.development?
  Rails.logger.info "✔ Users initialized"

  url = URI("https://adventofcode.com/#{2020}/leaderboard/private/view/#{1222761}.json")
  session_cookie = ENV['SESSION_COOKIE']
  https = Net::HTTP.new(url.host, url.port)
  https.use_ssl = true
  request = Net::HTTP::Get.new(url)
  request["Cookie"] = "session=#{session_cookie}"
  response = https.request(request)
  JSON(response.body)
  pr = JSON(response.body)
  members = pr['members']
  members.first
  members.each { |aoc_id, attrs| User.create!(username: attrs['name'], batch: Batch.all.sample, aoc_id: aoc_id) }
end
