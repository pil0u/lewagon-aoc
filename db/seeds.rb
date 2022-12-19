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
require "csv"
CSV.foreach("app/assets/batch_map.csv") do |row|
  city = City.find_by(name: row[1])
  city = City.create!(name: row[1]) if city.nil?

  batch = Batch.find_by(number: row[0].to_i)
  if batch
    Batch.update(batch.id, size: row[2].to_i, city_id: city.id)
  else
    Batch.create!(number: row[0].to_i, size: row[2].to_i, city_id: city.id)
  end
end

Rails.logger.info "✔ Cities initialized"

# Initialize some users in development
if Rails.env.development?
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
