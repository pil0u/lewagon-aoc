# frozen_string_literal: true

class InsertNewCompletionsJob < ApplicationJob
  queue_as :default

  def perform
    @completions_from_api = {}
    @completions = []

    ActiveRecord::Base.transaction do
      @state = State.create

      update_fetch_api_begin
      fetch_completions_from_aoc_api
      update_users_sync_status
      transform_completions_for_database
      insert_new_completions
      update_fetch_api_end
    end

    nil
  end

  private

  def update_fetch_api_begin
    now = Time.now.utc

    @state.update(fetch_api_begin: now)
    Rails.logger.info "🤖 Completions update started at #{now}"
  end

  def fetch_completions_from_aoc_api
    aoc_group_ids = Aoc.private_leaderboards.map { |id| id.split("-").first }

    aoc_group_ids.each do |aoc_group_id|
      current_group_completions = fetch_completions(aoc_group_id)

      @completions_from_api.deep_merge!(current_group_completions)
    end
  end

  def fetch_completions(id)
    Rails.logger.info "\tFetching data from leaderboard #{id}..."
    url = URI("https://adventofcode.com/2021/leaderboard/private/view/#{id}.json")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Cookie"] = "session=#{ENV.fetch('SESSION_COOKIE')}"
    response = https.request(request)
    Rails.logger.info "\t#{response.code} #{response.message}"

    JSON.parse(response.body)["members"]
  end

  def update_users_sync_status
    User.update_sync_status_from(@completions_from_api)
    Rails.logger.info "✔ Users sync status updated"
  end

  def transform_completions_for_database
    Rails.logger.info "\tTransforming JSON to match the completions table format..."

    users = User.pluck(:aoc_id, :id).to_h.except(nil)
    stored_completions = Completion.joins(:user).pluck(:aoc_id, :day, :challenge)
    now = Time.now.utc

    @completions_from_api.each do |aoc_id, results|
      user_id = users[aoc_id.to_i]
      next if user_id.nil?

      results["completion_day_level"].each do |day, challenges|
        challenges.each do |challenge, value|
          completion = {
            user_id:,
            day: day.to_i,
            challenge: challenge.to_i,
            completion_unix_time: value["get_star_ts"],
            created_at: now
          }

          # This helps limit the size of the INSERT query in spite of the default ON CONFLICT DO NOTHING
          @completions << completion unless [aoc_id, day, challenge].map(&:to_i).in?(stored_completions)
        end
      end
    end
  end

  def insert_new_completions
    if @completions.any?
      Completion.insert_all(@completions)
      Rails.logger.info "✔ #{@completions.size} new completions inserted"
    else
      Rails.logger.info "🤷 No completions to insert"
    end
  end

  def update_fetch_api_end
    now = Time.now.utc

    @state.update(fetch_api_end: now)
    Rails.logger.info "🏁 Completions update finished at #{now}"
  end
end
