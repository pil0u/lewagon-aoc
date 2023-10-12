require "csv"
require "cgi"
require "json"
require "net/http"

CSV_PATH = "db/static/batch_map.csv".freeze
SESSION_COOKIE = "".freeze

uids = Set.new
users = []
page_num = 1

CSV.foreach(CSV_PATH) { |row| uids.add(row.first) }

loop do
  uri = URI("https://kitt.lewagon.com/api/v1/users?page=#{page_num}")
  https = Net::HTTP.new(uri.hostname, uri.port)
  https.use_ssl = true

  request = Net::HTTP::Get.new(uri)
  request["Cookie"] = "_kitt2017_=#{SESSION_COOKIE}"

  response = https.request(request)
  data = JSON.parse(response.read_body)

  data["users"].each do |user|
    user = user["alumnus"]
    uid = user["id"]
    if uids.include?(uid.to_s)
      p "PAGE #{page_num}/#{data['page_count']} - Skipped user #{uid} because he's already included"
      next
    end

    batch_number = user["camp_slug"]
    unless batch_number.to_i > 0
      p "PAGE #{page_num}/#{data['page_count']} - Skipped user #{uid} because he has no batch"
      next
    end

    city_name = user["city"]
    batch_year = "20#{user['camp_date'][-2..]}"

    users << [uid, batch_number, batch_year, city_name]
    p "PAGE #{page_num}/#{data['page_count']} - Added user #{uid}"
  end

  break unless data["has_more"]

  page_num += 1
end

CSV.open(CSV_PATH, "a") do |csv|
  users.each { |user| csv << user }
end
