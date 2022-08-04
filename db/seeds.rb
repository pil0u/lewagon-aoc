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
cities = {
  "Amsterdam" =>      525,
  "Bali" =>           296,
  "Barcelona" =>      473,
  "Belize" =>         14,
  "Belo Horizonte" => 22,
  "Berlin" =>         1839,
  "Bordeaux" =>       577,
  "Brasilia" =>       116,
  "Brussels" =>       546,
  "Buenos Aires" =>   236,
  "Casablanca" =>     80,
  "Chengdu" =>        64,
  "Cologne" =>        40,
  "Dubai" =>          35,
  "Istanbul" =>       30,
  "Kyoto" =>          18,
  "Lausanne" =>       158,
  "Lille" =>          422,
  "Lima" =>           53,
  "Lisbon" =>         734,
  "London" =>         1700,
  "Lyon" =>           454,
  "Madrid" =>         128,
  "Malmö" =>          21,
  "Marseille" =>      520,
  "Martinique" =>     29,
  "Mauritius" =>      96,
  "Medellín" =>       74,
  "Melbourne" =>      343,
  "Mexico" =>         209,
  "Milan" =>          137,
  "Montréal" =>       482,
  "Munich" =>         197,
  "Nantes" =>         276,
  "Nice" =>           93,
  "Paris" =>          2795,
  "Porto" =>          12,
  "Remote" =>         198,
  "Rennes" =>         56,
  "Rio de Janeiro" => 398,
  "Santiago" =>       98,
  "São Paulo" =>      692,
  "Seine et Marne" => 11,
  "Seoul" =>          16,
  "Shanghai" =>       360,
  "Shenzhen" =>       24,
  "Singapore" =>      253,
  "Stockholm" =>      51,
  "Tel Aviv" =>       159,
  "Tokyo" =>          521,
  "Zurich" =>         17
}.map do |city, size|
  { name: city, size: size }
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
                   aoc_id: 1_266_664
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
                 },
                 {
                   username: "test_6",
                   batch: Batch.find_by(number: 454),
                   aoc_id: 1_259_034
                 },
                 {
                   username: "test_7",
                   batch: Batch.find_by(number: 454),
                   aoc_id: 1_259_062
                 },
                 {
                   username: "test_8",
                   batch: Batch.find_by(number: 343),
                   aoc_id: 1_259_379
                 }
               ])
  Rails.logger.info "✔ Users initialized"
end
