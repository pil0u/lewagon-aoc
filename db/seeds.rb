# frozen_string_literal: true

# Initialize unique state row
State.create!(
  {
    last_api_fetch_start: nil,
    last_api_fetch_end: nil
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
  User.create!([
                 {
                   username: "test_1",
                   batch: Batch.create!(number: 343),
                   aoc_id: 151_323
                 },
                 {
                   username: "test_2",
                   batch: Batch.create!(number: 454),
                   aoc_id: 1_095_582
                 },
                 {
                   username: "test_3",
                   batch: Batch.create!(number: 123),
                   aoc_id: 1_222_761
                 },
                 {
                   username: "test_4",
                   batch: Batch.find_by(number: 123),
                   aoc_id: 1_237_086
                 },
                 {
                   username: "test_5",
                   batch: Batch.find_by(number: 123),
                   aoc_id: 1_258_899
                 }
               ])
  Rails.logger.info "✔ Users initialized"
end
