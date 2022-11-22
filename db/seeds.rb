# frozen_string_literal: true

# Initialize unique state row
State.create!(
  {
    fetch_api_begin: Time.at(0).utc,
    fetch_api_end: Time.at(0).utc
  }
)
Rails.logger.info "✔ States initialized"

# Initialize cities
cities = [
  ["Amsterdam",       555],
  ["Bali",            314],
  ["Barcelona",       506],
  ["Belize",          14],
  ["Belo Horizonte",  22],
  ["Berlin",          1978],
  ["Bordeaux",        615],
  ["Brasilia",        134],
  ["Brussels ⭐",      732],
  ["Buenos Aires",    268],
  ["Casablanca",      88],
  ["Chengdu",         64],
  ["Cologne",         52],
  ["Dubai",           35],
  ["Emil",            124],
  ["For Business",    87],
  ["Istanbul",        30],
  ["Kyoto",           18],
  ["Lausanne",        170],
  ["Lille",           438],
  ["Lima",            53],
  ["Lisbon",          829],
  ["London",          1882],
  ["Lyon",            483],
  ["Madrid",          162],
  ["Malmö",           21],
  ["Marseille",       565],
  ["Martinique",      42],
  ["Mauritius",       117],
  ["Medellín",        71],
  ["Melbourne",       386],
  ["Mexico",          231],
  ["Milan",           137],
  ["Montréal",        534],
  ["Munich",          219],
  ["Nantes",          303],
  ["Nice",            122],
  ["Paris",           3108],
  ["Porto",           21],
  ["Remote",          417],
  ["Rennes",          67],
  ["Rio de Janeiro",  427],
  ["Santiago",        98],
  ["São Paulo",       746],
  ["Seine et Marne",  11],
  ["Shanghai",        386],
  ["Shenzhen",        24],
  ["Singapore",       309],
  ["Stockholm",       51],
  ["Tel Aviv",        158],
  ["Tokyo",           592],
  ["Zurich",          30]
].map do |city|
  { name: city[0], size: city[1] }
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
