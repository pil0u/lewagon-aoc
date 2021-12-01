# frozen_string_literal: true

require "aoc"

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[home]

  MAGIC_DAYS = [17, 24, 1, 8, 15, 23, 5, 7, 14, 16, 4, 6, 13, 20, 22, 10, 12, 19, 21, 3, 11, 18, 25, 2, 9].freeze

  def home
    @total_sign_ins = User.count
  end

  def about
    @ranking_example = [
      { user_id: 14,  day: 1, challenge: 1, time: "1 minute",           score: 5 },
      { user_id: 32,  day: 1, challenge: 1, time: "1 minute 1 second",  score: 4 },
      { user_id: 18,  day: 1, challenge: 1, time: "1 hour",             score: 3 },
      { user_id: 5,   day: 1, challenge: 1, time: "2 hours",            score: 2 },
      { user_id: 97,  day: 1, challenge: 1, time: "5 days",             score: 1 },
      { user_id: 14,  day: 1, challenge: 2, time: "never",              score: 0 },
      { user_id: 32,  day: 1, challenge: 2, time: "6 hours",            score: 4 },
      { user_id: 18,  day: 1, challenge: 2, time: "6 days",             score: 2 },
      { user_id: 5,   day: 1, challenge: 2, time: "3 hours",            score: 5 },
      { user_id: 97,  day: 1, challenge: 2, time: "5 days 2 hours",     score: 3 }
    ]
    @ranking_example_updated = [
      { user_id: 14,  day: 1, challenge: 1, time: "1 minute",           score: 12 },
      { user_id: 32,  day: 1, challenge: 1, time: "1 minute 1 second",  score: 11 },
      { user_id: 18,  day: 1, challenge: 1, time: "1 hour",             score: 10 },
      { user_id: 5,   day: 1, challenge: 1, time: "2 hours",            score: 9 },
      { user_id: 97,  day: 1, challenge: 1, time: "5 days",             score: 8 },
      { user_id: 14,  day: 1, challenge: 2, time: "never",              score: 0 },
      { user_id: 32,  day: 1, challenge: 2, time: "6 hours",            score: 11 },
      { user_id: 18,  day: 1, challenge: 2, time: "6 days",             score: 9 },
      { user_id: 5,   day: 1, challenge: 2, time: "3 hours",            score: 12 },
      { user_id: 97,  day: 1, challenge: 2, time: "5 days 2 hours",     score: 10 }
    ]
  end

  def dashboard
    # Time
    @now = Time.now.getlocal("-05:00")
    
    now_utc = Time.now.utc
    last_api_fetch_utc = State.first.last_api_fetch_end
    @time_since_last_api_fetch = helpers.distance_of_time_in_words(last_api_fetch_utc, now_utc)

    if now_utc < last_api_fetch_utc + 10.minutes
      @estimated_next_api_fetch = helpers.distance_of_time_in_words(last_api_fetch_utc + 10.minutes, now_utc)
    else
      @estimated_next_api_fetch = "soon™"
    end

    next_puzzle_time = Aoc.next_puzzle_time_from(@now)
    @time_to_next_puzzle = helpers.distance_of_time_in_words(@now, next_puzzle_time)

    # Event
    @aoc_in_progress = Aoc.in_progress?
    @year = ENV["EVENT_YEAR"] || 2021
    @current_open_room = ENV["AOC_ROOMS"].split(",").last
    @user_status = current_user.status

    # User stats

    ## Individual rank & scores
    fields = %i[user_id score_solo score_in_batch score_in_city]
    ranked_users = Score.includes(:user)
                        .group("users.id, users.username")
                        .order("sum(score_solo) desc, users.id desc")
                        .pluck("users.id", "sum(score_solo)", "sum(score_in_batch)", "sum(score_in_city)")
                        .map { |row| fields.zip(row).to_h }
                        .map.with_index { |h, idx| h.merge!(rank_solo: idx + 1) }

    @user_score = ranked_users.find { |h| h[:user_id] == current_user.id }
    @total_users = ranked_users.count

    ## Batch rank & score
    @user_batch = current_user.batch

    if @user_batch
      fields = %i[batch_id batch_score]
      ranked_batches = Score.includes(user: :batch)
                            .group("batches.id, batches.number")
                            .order("sum(score_in_batch) desc, batches.number")
                            .pluck("batches.id", "sum(score_in_batch)")
                            .map { |row| fields.zip(row).to_h }
                            .reject { |h| h[:batch_id].nil? }
                            .map.with_index { |h, idx| h.merge!(batch_rank: idx + 1) }

      @user_batch_score = ranked_batches.find { |h| h[:batch_id] == @user_batch.id }
      @total_batches = ranked_batches.count
    end

    ## City rank & score
    @user_city = current_user.city

    if @user_city
      fields = %i[city_id city_score]
      ranked_cities = Score.includes(user: :city)
                           .group("cities.id, cities.name")
                           .order("sum(score_in_city) desc, cities.name")
                           .pluck("cities.id", "sum(score_in_city)")
                           .map { |row| fields.zip(row).to_h }
                           .reject { |h| h[:city_id].nil? }
                           .map.with_index { |h, idx| h.merge!(city_rank: idx + 1) }

      @user_city_score = ranked_cities.find { |h| h[:city_id] == @user_city.id }
      @total_cities = ranked_cities.count
    end

    # Calendar
    @advent_days = MAGIC_DAYS.map { |advent_day| Time.new(2021, 12, advent_day, 0, 0, 0, "-05:00") }
  end

  def scoreboard
    fields = %i[city_name city_n_users city_score]
    @ranked_cities = Score.includes(user: :city)
                          .group("cities.name")
                          .order("sum(score_in_city) desc, cities.name")
                          .pluck("cities.name", Arel.sql("count(distinct users.id)"), "sum(score_in_city)")
                          .map { |row| fields.zip(row).to_h }
                          .reject { |h| h[:city_name].nil? }
                          .map.with_index { |h, idx| h.merge!(city_rank: idx + 1) }

    @max_city_contributors = City.max_contributors

    fields = %i[batch_number batch_n_users batch_score]
    @ranked_batches = Score.includes(user: :batch)
                           .group("batches.number")
                           .order("sum(score_in_batch) desc, batches.number")
                           .pluck("batches.number", Arel.sql("count(distinct users.id)"), "sum(score_in_batch)")
                           .map { |row| fields.zip(row).to_h }
                           .reject { |h| h[:batch_number].nil? }
                           .map.with_index { |h, idx| h.merge!(batch_rank: idx + 1) }

    @max_batch_contributors = Batch.max_contributors

    fields = %i[uid username batch city score_solo]
    @ranked_users = Score.includes(user: %i[batch city])
                         .group("users.id, users.username")
                         .order("sum(score_solo) desc, users.id desc")
                         .pluck("users.uid", "users.username", "max(batches.number)", "max(cities.name)", "sum(score_solo)")
                         .map { |row| fields.zip(row).to_h }
                         .map.with_index { |h, idx| h.merge!(rank: idx + 1) }
  end
end
