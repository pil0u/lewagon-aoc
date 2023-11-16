# frozen_string_literal: true

# Initialize unique state row
State.create!(
  {
    fetch_api_begin: Time.at(0).utc,
    fetch_api_end: Time.at(0).utc
  }
)
Rails.logger.info "✔ States initialized"

# Initialize cities & batch

if Rails.env.development?
  City.destroy_all
  Batch.destroy_all
end

cities = [
  { name: "Amsterdam",        size: 666 },
  { name: "B2G Latam",        size: 105 },
  { name: "Bali",             size: 421 },
  { name: "Barcelona",        size: 610 },
  { name: "Beirut",           size: 14 },
  { name: "Belo Horizonte",   size: 22 },
  { name: "Berlin",           size: 2563 },
  { name: "Bordeaux",         size: 712 },
  { name: "Brasilia",         size: 134 },
  { name: "Brussels",         size: 837 },
  { name: "Buenos Aires",     size: 397 },
  { name: "Cape Town",        size: 92 },
  { name: "Casablanca",       size: 143 },
  { name: "Chengdu",          size: 64 },
  { name: "Cologne",          size: 97 },
  { name: "Copenhagen",       size: 117 },
  { name: "Dubai",            size: 35 },
  { name: "Emil",             size: 172 },
  { name: "Essonne",          size: 16 },
  { name: "For Business",     size: 217 },
  { name: "Istanbul",         size: 30 },
  { name: "Kyoto",            size: 18 },
  { name: "Lausanne",         size: 191 },
  { name: "Lille",            size: 484 },
  { name: "Lima",             size: 53 },
  { name: "Lisbon",           size: 1037 },
  { name: "London",           size: 2366 },
  { name: "Lyon",             size: 575 },
  { name: "Madrid",           size: 209 },
  { name: "Malmö",            size: 21 },
  { name: "Marseille",        size: 687 },
  { name: "Martinique",       size: 42 },
  { name: "Mauritius",        size: 184 },
  { name: "Medellín",         size: 71 },
  { name: "Melbourne",        size: 468 },
  { name: "Mexico",           size: 301 },
  { name: "Milan",            size: 137 },
  { name: "Montréal",         size: 645 },
  { name: "Munich",           size: 293 },
  { name: "Nantes",           size: 375 },
  { name: "Nice",             size: 200 },
  { name: "Online",           size: 1696 },
  { name: "Oslo",             size: 55 },
  { name: "Paris",            size: 4189 },
  { name: "Porto",            size: 53 },
  { name: "Rennes",           size: 77 },
  { name: "Rio de Janeiro",   size: 488 },
  { name: "Riyadh",           size: 74 },
  { name: "Santiago",         size: 98 },
  { name: "Seine et Marne",   size: 25 },
  { name: "Seoul",            size: 16 },
  { name: "Shanghai",         size: 435 },
  { name: "Shenzhen",         size: 24 },
  { name: "Singapore",        size: 402 },
  { name: "Stockholm",        size: 51 },
  { name: "Sydney",           size: 2 },
  { name: "São Paulo",        size: 1043 },
  { name: "Tel Aviv",         size: 158 },
  { name: "Testville",        size: 7 },
  { name: "Tokyo",            size: 816 },
  { name: "Toulouse",         size: 20 },
  { name: "Zurich",           size: 64 }
]
cities.each do |city|
  c = City.find_or_create_by(name: city[:name])
  c.update(size: city[:size])
end

Rails.logger.info "✔ Cities initialized"

# Initialize some users in development
if Rails.env.development?
  User.destroy_all
  User.create!([
                 {
                   username: "test_1",
                   batch: Batch.find_or_create_by(number: 343),
                   city: City.find_by(name: "Paris"),
                   aoc_id: 151_323,
                   uid: 1
                 },
                 {
                   username: "test_2",
                   batch: Batch.find_or_create_by(number: 454),
                   city: City.find_by(name: "Paris"),
                   aoc_id: 1_095_582,
                   uid: 2
                 },
                 {
                   username: "test_3",
                   batch: Batch.find_or_create_by(number: 123),
                   city: City.find_by(name: "Bordeaux"),
                   aoc_id: 1_266_664,
                   uid: 3
                 },
                 {
                   username: "test_4",
                   batch: Batch.find_or_create_by(number: 123),
                   city: City.find_by(name: "London"),
                   aoc_id: 1_237_086,
                   uid: 4
                 },
                 {
                   username: "test_5",
                   batch: Batch.find_or_create_by(number: 123),
                   city: City.find_by(name: "London"),
                   aoc_id: 1_258_899,
                   uid: 5
                 },
                 {
                   username: "test_6",
                   batch: Batch.find_or_create_by(number: 454),
                   city: City.find_by(name: "Paris"),
                   aoc_id: 1_259_034,
                   uid: 6
                 },
                 {
                   username: "test_7",
                   batch: Batch.find_or_create_by(number: 454),
                   city: City.find_by(name: "Brussels"),
                   aoc_id: 1_259_062,
                   uid: 7
                 },
                 {
                   username: "test_8",
                   batch: Batch.find_or_create_by(number: 343),
                   city: City.find_by(name: "Paris"),
                   aoc_id: 1_259_379,
                   uid: 8
                 }
               ])
  Rails.logger.info "✔ Users initialized"
end
