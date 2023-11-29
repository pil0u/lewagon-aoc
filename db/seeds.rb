# frozen_string_literal: true

# Initialize unique state row
State.create!(
  {
    fetch_api_begin: Time.at(0).utc,
    fetch_api_end: Time.at(0).utc
  }
)
Rails.logger.info "✔ States initialized"

# Initialize campuses
if Rails.env.development?
  City.destroy_all
  Batch.destroy_all
end

campuses = [
  { name: "Amsterdam",      size: 668 },
  { name: "B2G Latam",      size: 105 },  # not in export
  { name: "Bali",           size: 423 },
  { name: "Barcelona",      size: 611 },
  { name: "Beirut",         size: 14 },  # not in export
  { name: "Belize",         size: 139 },
  { name: "Belo Horizonte", size: 22 },  # not in export
  { name: "Berlin",         size: 2598 },
  { name: "Bordeaux",       size: 713 },
  { name: "Brasilia",       size: 134 },  # not in export
  { name: "Brussels",       size: 838 },
  { name: "Buenos Aires",   size: 419 },
  { name: "Cape Town",      size: 92 },
  { name: "Casablanca",     size: 163 },
  { name: "Chengdu",        size: 64 },
  { name: "Cologne",        size: 98 },
  { name: "Copenhagen",     size: 117 },  # not in export
  { name: "Dubai",          size: 35 },  # not in export
  { name: "Emil",           size: 173 },
  { name: "Essonne",        size: 16 },
  { name: "For Business",   size: 219 },
  { name: "Istanbul",       size: 30 },  # not in export
  { name: "Kyoto",          size: 18 },  # not in export
  { name: "Lausanne",       size: 204 },
  { name: "Lille",          size: 484 },
  { name: "Lima",           size: 53 },  # not in export
  { name: "Lisbon",         size: 1040 },
  { name: "London",         size: 2427 },
  { name: "Lyon",           size: 576 },
  { name: "Madrid",         size: 211 },
  { name: "Malmö",          size: 21 },  # not in export
  { name: "Marseille",      size: 729 },
  { name: "Martinique",     size: 55 },
  { name: "Mauritius",      size: 199 },
  { name: "Medellín",       size: 71 },  # not in export
  { name: "Melbourne",      size: 537 },
  { name: "Mexico",         size: 315 },
  { name: "Milan",          size: 137 },  # not in export
  { name: "Montréal",       size: 655 },
  { name: "Munich",         size: 294 },
  { name: "Nantes",         size: 375 },
  { name: "Nice",           size: 209 },
  { name: "Online",         size: 1861 },
  { name: "Oslo",           size: 55 },  # not in export
  { name: "Paris",          size: 4347 },
  { name: "Porto",          size: 53 },
  { name: "Rennes",         size: 77 },
  { name: "Rio de Janeiro", size: 488 },
  { name: "Riyadh",         size: 74 },
  { name: "Santiago",       size: 98 },
  { name: "Seine et Marne", size: 25 },
  { name: "Seoul",          size: 16 },  # not in export
  { name: "Shanghai",       size: 453 },
  { name: "Shenzhen",       size: 24 },  # not in export
  { name: "Singapore",      size: 428 },
  { name: "Stockholm",      size: 51 },  # not in export
  { name: "Sydney",         size: 2 },
  { name: "São Paulo",      size: 1097 },
  { name: "Tel Aviv",       size: 158 },  # not in export
  { name: "Tokyo",          size: 879 },
  { name: "Toulouse",       size: 20 },
  { name: "Zurich",         size: 64 }
]

campuses.each do |campus|
  c = City.find_or_create_by(name: campus[:name])
  c.update(size: campus[:size])
end
Rails.logger.info "✔ Campuses initialized"

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
