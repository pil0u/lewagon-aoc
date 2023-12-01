# frozen_string_literal: true

# Initialize unique state row
unless State.exists?
  State.create!(
    {
      fetch_api_begin: Time.at(0).utc,
      fetch_api_end: Time.at(0).utc
    }
  )
  Rails.logger.info "✔ States initialized"
end

# Initialize campuses
if Rails.env.development?
  City.destroy_all
  Batch.destroy_all
end

campuses = [
  { name: "Amsterdam",      size: 668,  top_contributors: 14 },
  { name: "B2G Latam",      size: 105,  top_contributors: 10 },  # not in export
  { name: "Bali",           size: 423,  top_contributors: 11 },
  { name: "Barcelona",      size: 611,  top_contributors: 13 },
  { name: "Beirut",         size: 14,   top_contributors: 10 },  # not in export
  { name: "Belize",         size: 139,  top_contributors: 10 },
  { name: "Belo Horizonte", size: 22,   top_contributors: 10 },  # not in export
  { name: "Berlin",         size: 2598, top_contributors: 63 },
  { name: "Bordeaux",       size: 713,  top_contributors: 14 },
  { name: "Brasilia",       size: 134,  top_contributors: 10 },  # not in export
  { name: "Brussels",       size: 838,  top_contributors: 18 },
  { name: "Buenos Aires",   size: 419,  top_contributors: 13 },
  { name: "Cape Town",      size: 92,   top_contributors: 10 },
  { name: "Casablanca",     size: 163,  top_contributors: 10 },
  { name: "Chengdu",        size: 64,   top_contributors: 10 },  # not in export
  { name: "Cologne",        size: 98,   top_contributors: 10 },
  { name: "Copenhagen",     size: 117,  top_contributors: 10 },  # not in export
  { name: "Dubai",          size: 35,   top_contributors: 10 },  # not in export
  { name: "Emil",           size: 173,  top_contributors: 10 },
  { name: "Essonne",        size: 16,   top_contributors: 10 },
  { name: "For Business",   size: 219,  top_contributors: 10 },
  { name: "Istanbul",       size: 30,   top_contributors: 10 },  # not in export
  { name: "Kyoto",          size: 18,   top_contributors: 10 },  # not in export
  { name: "Lausanne",       size: 204,  top_contributors: 10 },
  { name: "Lille",          size: 484,  top_contributors: 10 },
  { name: "Lima",           size: 53,   top_contributors: 10 },  # not in export
  { name: "Lisbon",         size: 1040, top_contributors: 23 },
  { name: "London",         size: 2427, top_contributors: 57 },
  { name: "Lyon",           size: 576,  top_contributors: 12 },
  { name: "Madrid",         size: 211,  top_contributors: 10 },
  { name: "Malmö",          size: 21,   top_contributors: 10 },  # not in export
  { name: "Marseille",      size: 729,  top_contributors: 15 },
  { name: "Martinique",     size: 55,   top_contributors: 10 },
  { name: "Mauritius",      size: 199,  top_contributors: 10 },
  { name: "Medellín",       size: 71,   top_contributors: 10 },  # not in export
  { name: "Melbourne",      size: 537,  top_contributors: 13 },
  { name: "Mexico",         size: 315,  top_contributors: 10 },
  { name: "Milan",          size: 137,  top_contributors: 10 },  # not in export
  { name: "Montréal",       size: 655,  top_contributors: 14 },
  { name: "Munich",         size: 294,  top_contributors: 10 },
  { name: "Nantes",         size: 375,  top_contributors: 10 },
  { name: "Nice",           size: 209,  top_contributors: 10 },
  { name: "Online",         size: 1861, top_contributors: 85 },
  { name: "Oslo",           size: 55,   top_contributors: 10 },  # not in export
  { name: "Paris",          size: 4347, top_contributors: 105 },
  { name: "Porto",          size: 53,   top_contributors: 10 },
  { name: "Rennes",         size: 77,   top_contributors: 10 },
  { name: "Rio de Janeiro", size: 488,  top_contributors: 10 },
  { name: "Riyadh",         size: 74,   top_contributors: 10 },
  { name: "Santiago",       size: 98,   top_contributors: 10 },
  { name: "Seine et Marne", size: 25,   top_contributors: 10 },
  { name: "Seoul",          size: 16,   top_contributors: 10 },  # not in export
  { name: "Shanghai",       size: 453,  top_contributors: 10 },
  { name: "Shenzhen",       size: 24,   top_contributors: 10 },  # not in export
  { name: "Singapore",      size: 428,  top_contributors: 12 },
  { name: "Stockholm",      size: 51,   top_contributors: 10 },  # not in export
  { name: "Sydney",         size: 2,    top_contributors: 10 },
  { name: "São Paulo",      size: 1097, top_contributors: 30 },
  { name: "Tel Aviv",       size: 158,  top_contributors: 10 },  # not in export
  { name: "Tokyo",          size: 879,  top_contributors: 24 },
  { name: "Toulouse",       size: 20,   top_contributors: 10 },
  { name: "Zurich",         size: 64,   top_contributors: 10 }
]

campuses.each do |campus|
  c = City.find_or_create_by(name: campus[:name])
  c.update(size: campus[:size], top_contributors: campus[:top_contributors])
end
Rails.logger.info "✔ Campuses upserted"

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
