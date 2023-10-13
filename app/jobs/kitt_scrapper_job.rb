# frozen_string_literal: true

require "csv"
require "net/http"

class KittScrapperJob < ApplicationJob
  CSV_PATH = "db/static/batch_map.csv"

  # User: [uid, batch_number, batch_year, city_name]
  def perform(args = {})
    @users = CSV.table(CSV_PATH, headers: false).to_a # Array<User>
    fetch_kitt if args[:fetch_kitt]
    update_batches if args[:update_batches]
  end

  private

  def append_new_users_to_csv
    CSV.open(CSV_PATH, "a") do |csv|
      @new_users.each { |user| csv << user }
    end
  end

  def fetch(url)
    uri = URI(url)
    https = Net::HTTP.new(uri.hostname, uri.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request["Cookie"] = "_kitt2017_=#{ENV.fetch('KITT_SESSION_COOKIE')}"

    https.request(request)
  end

  def fetch_kitt
    @uids = @users.map.with_object(Set.new) { |user, set| set.add(user[0]) }
    @new_users = []
    @page_num = 1

    loop do
      response = fetch("https://kitt.lewagon.com/api/v1/users?page=#{@page_num}")
      data = JSON.parse(response.read_body)

      push_new_users(data["users"])

      @page_num += 1
      break unless data["has_more"]
    end

    append_new_users_to_csv
  end

  def push_new_users(users)
    users.each do |user|
      user = user["alumnus"]
      uid = user["id"]
      next if @uids.include?(uid.to_s)

      batch_number = user["camp_slug"]
      next unless batch_number.to_i > 0

      city_name = user["city"]
      batch_year = "20#{user['camp_date'][-2..]}"
      @new_users << [uid, batch_number, batch_year, city_name]
    end
  end

  # CityOfUsers: Array<[city_name, Array<User>]>
  # CityOfBatches: Array<[city_name, city_size, Array<[batch_number, Array<User>]>]>
  def update_batches
    @users
      .group_by { |user| user[3] }.entries # CityOfUsers
      .map { |city_name, users| [city_name, users.length, users.group_by { |user| user[1] }.entries] } # CityOfBatches
      .each do |city_name, city_size, batches|
        city = City.find_or_initialize_by(name: city_name)
        city.update!(size: city_size)

        batches.each do |batch_number, users|
          batch = Batch.find_or_initialize_by(number: batch_number)
          batch.update!(year: users.first[2], size: users.length, city:)
        end
      end
  end
end
