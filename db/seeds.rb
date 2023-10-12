# frozen_string_literal: true

require "csv"

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

csv_users = CSV.table("db/static/batch_map.csv", headers: false).to_a
csv_users
  .group_by { |user| user[3] }.entries
  # Array<[city_name, Array<[uid, batch_number, batch_year, city_name]>]>
  .map { |city_name, users| [city_name, users.length, users.group_by { |user| user[1] }.entries] }
  # Array<[city_name, city_size, Array<[batch_number, Array<[uid, batch_number, batch_year, city_name]>]>]>
  .each do |city_name, city_size, batches|
    city = City.find_or_initialize_by(name: city_name)
    city.update!(size: city_size)

    batches.each do |batch_number, users|
      batch = Batch.find_or_initialize_by(number: batch_number)
      batch.update!(year: users.first[2], size: users.length, city:)
    end
  end

Rails.logger.info "✔ Cities initialized"

# Initialize some users in development
if Rails.env.development?
  User.destroy_all
  User.create!([
                 {
                   username: "test_1",
                   batch: Batch.find_by(number: 343),
                   aoc_id: 151_323,
                   uid: 1
                 },
                 {
                   username: "test_2",
                   batch: Batch.find_by(number: 454),
                   aoc_id: 1_095_582,
                   uid: 2
                 },
                 {
                   username: "test_3",
                   batch: Batch.find_by(number: 123),
                   aoc_id: 1_266_664,
                   uid: 3
                 },
                 {
                   username: "test_4",
                   batch: Batch.find_by(number: 123),
                   aoc_id: 1_237_086,
                   uid: 4
                 },
                 {
                   username: "test_5",
                   batch: Batch.find_by(number: 123),
                   aoc_id: 1_258_899,
                   uid: 5
                 },
                 {
                   username: "test_6",
                   batch: Batch.find_by(number: 454),
                   aoc_id: 1_259_034,
                   uid: 6
                 },
                 {
                   username: "test_7",
                   batch: Batch.find_by(number: 454),
                   aoc_id: 1_259_062,
                   uid: 7
                 },
                 {
                   username: "test_8",
                   batch: Batch.find_by(number: 343),
                   aoc_id: 1_259_379,
                   uid: 8
                 }
               ])
  Rails.logger.info "✔ Users initialized"
end
