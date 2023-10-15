# frozen_string_literal: true

require "csv"
require "net/http"

class KittScraperJob < ApplicationJob
  CSV_PATH = "db/static/kitt_alumni.csv"

  def perform(scrape_kitt: true, upsert_data: true)
    perform_scrape_kitt if scrape_kitt
    perform_upsert_data if upsert_data
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

  def perform_scrape_kitt
    @known_uids = CSV.read(CSV_PATH, headers: true).pluck("uid").to_set(&:to_i)
    @new_users = []
    page = 1

    loop do
      data = JSON.parse(fetch("https://kitt.lewagon.com/api/v1/users?page=#{page}").read_body)
      Rails.logger.info("Scraping page #{@page}/#{data['page_count']}...")

      push_new_users(data["users"])

      page += 1
      break unless data["has_more"]
    end

    append_new_users_to_csv
  end

  def perform_upsert_data
    cities = Hash.new { |city_hash, city| city_hash[city] = Hash.new(0) }
    CSV.foreach(CSV_PATH, headers: true) { |row| cities[row["city_name"]][row["batch_number"]] += 1 }

    cities.each do |city_name, batches|
      city = City.find_or_initialize_by(name: city_name)
      city.update!(size: batches.values.sum)

      batches.each do |batch_number, size|
        batch = Batch.find_or_initialize_by(number: batch_number)
        batch.update!(size:, city:)
      end
    end
  end

  def push_new_users(users)
    users.each do |user|
      alumnus = user["alumnus"]
      uid = alumnus["id"]
      next if @known_uids.include?(uid)

      batch_number = alumnus["camp_slug"].to_i
      next if batch_number == 0

      city_name = alumnus["city"]
      batch_year = Date.parse(alumnus["camp_date"]).year
      @new_users << [uid, batch_number, batch_year, city_name]
    end
  end
end
