# frozen_string_literal: true

module Completions
  class Fetcher
    def self.call(...)
      new.call(...)
    end

    def call
      ActiveRecord::Base.transaction do
        log_timing do
          api_completions = fetch_completions_from_aoc_api
          Rails.logger.info "✔ Completions fetched"

          update_users_sync_status(api_completions.keys)
          Rails.logger.info "✔ Users' sync status updated"

          completion_attributes = transform_for_database(api_completions)
          Rails.logger.info \
            "✔ Completions prepared for database import (total: #{completion_attributes.size})"

          if completion_attributes.any?
            inserted = insert_into_db(completion_attributes)
            Rails.logger.info "✔ #{inserted} new completions inserted"
          else
            Rails.logger.info "🤷 No completions to insert"
          end
        end
      end

      launch_cache_refresh
      true
    end

    private

    def log_timing
      state = State.create(fetch_api_begin: Time.zone.now)
      Rails.logger.info "🤖 Completions update started at #{state.fetch_api_begin}"

      yield

      state.update(fetch_api_end: Time.zone.now)
      Rails.logger.info "🏁 Completions update finished at #{state.fetch_api_end}"
    end

    def fetch_completions_from_aoc_api
      aoc_group_ids = Aoc.private_leaderboards.map { |id| id.split("-").first }

      aoc_group_ids.reduce({}) do |api_completions, aoc_group_id|
        api_completions.deep_merge! fetch_completions(aoc_group_id)
      end
    end

    def fetch_completions(id)
      Rails.logger.info "\tFetching data from leaderboard #{id}..."
      url = URI("https://adventofcode.com/2022/leaderboard/private/view/#{id}.json")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["Cookie"] = "session=#{ENV.fetch('SESSION_COOKIE')}"
      response = https.request(request)
      Rails.logger.info "\t#{response.code} #{response.message}"

      JSON.parse(response.body)["members"]
    end

    def update_users_sync_status(participant_ids)
      to_sync = User.where(aoc_id: participant_ids).where.not(synced: true)
      to_unsync = User.where.not(aoc_id: participant_ids).where(synced: true)

      to_sync.update(synced: true)
      to_unsync.update(synced: false)

      to_sync.pluck(:id, :github_username).each do |(id, github_username)|
        Rails.logger.info "\t#{id}-#{github_username} is now synced."
      end
      to_unsync.pluck(:id, :github_username).each do |(id, github_username)|
        Rails.logger.info "\t#{id}-#{github_username} is now unsynced."
      end
    end

    def transform_for_database(api_completions)
      now = Time.now.utc
      users = User.pluck(:aoc_id, :id).to_h.except(nil)
      stored_completions = Completion.joins(:user).pluck(:aoc_id, :day, :challenge)

      api_completions.each_with_object([]) do |(aoc_id, results), to_insert|
        user_id = users[aoc_id.to_i]
        next if user_id.nil? # Unknown user

        user_completions = results["completion_day_level"]
        user_completions.each_with_object(to_insert) do |(day, challenges), completions|
          challenges.each do |challenge, value|
            # This helps limit the size of the INSERT query
            # even if we have a ON CONFLICT DO NOTHING default
            next if stored_completions.include? [aoc_id, day, challenge].map(&:to_i)

            completions << {
              user_id:,
              day: day.to_i,
              challenge: challenge.to_i,
              completion_unix_time: value["get_star_ts"],
              created_at: now
            }
          end
        end
      end
    end

    def insert_into_db(completions)
      Completion.insert_all(completions).count
    end

    def launch_cache_refresh
      Cache::PopulateJob.perform_later
    end
  end
end
