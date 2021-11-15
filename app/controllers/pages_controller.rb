# frozen_string_literal: true

require "aoc"
require "help"

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[home]

  MAGIC_DAYS = [17, 24, 1, 8, 15, 23, 5, 7, 14, 16, 4, 6, 13, 20, 22, 10, 12, 19, 21, 3, 11, 18, 25, 2, 9].freeze

  def home
    @user_count = User.count
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
    @now = Time.now.getlocal("-05:00")

    @status = current_user.status
    @last_api_fetch = State.first.last_api_fetch_end
    @estimated_next_api_fetch = @now.utc < @last_api_fetch + 10.minutes ? helpers.distance_of_time_in_words(@last_api_fetch + 10.minutes, @now.utc) : "soon™"

    @aoc_in_progress = Aoc.in_progress?
    @year = ENV["EVENT_YEAR"] || 2021

    sorted_users = Score.group(:user_id).sum(:score_solo).sort_by { |_k, v| -v }
    @my_score = current_user.scores.sum(:score_solo)
    @my_rank = sorted_users.index([current_user.id, @my_score])&.+1

    @sorted_batches = Score.includes(user: :batch).group(:batch_id).sum(:score_in_batch).except(nil).sort_by { |_k, v| -v }
    if current_user.batch
      @my_batch_score = current_user.batch.scores.sum(:score_in_batch)
      @my_batch_rank = @sorted_batches.index([current_user.batch.id, @my_batch_score])&.+1
      @my_score_in_batch = current_user.scores.sum(:score_in_batch)
    end

    @sorted_cities = Score.includes(user: :city).group(:city_id).sum(:score_in_city).except(nil).sort_by { |_k, v| -v }
    if current_user.city
      @my_city_score = current_user.city.scores.sum(:score_in_city)
      @my_city_rank = @sorted_cities.index([current_user.city.id, @my_city_score])&.+1
      @my_score_in_city = current_user.scores.sum(:score_in_city)
    end

    @next_puzzle_time = Aoc.next_puzzle_time_from(@now)

    @advent_days = MAGIC_DAYS.map { |advent_day| Time.new(2021, 12, advent_day, 0, 0, 0, "-05:00") }
  end

  def scoreboard
    @max_city_contributors = Help.median(User.group(:city_id).count.except(nil).values) || 1
    @sorted_cities = Score.includes(user: :city)
                          .group(:city_id)
                          .sum(:score_in_city)
                          .except(nil)
                          .transform_keys { |k| City.find(k).name }
                          .sort_by { |_k, v| -v }

    @max_batch_contributors = Help.median(User.group(:batch_id).count.except(nil).values) || 1
    @sorted_batches = Score.includes(user: :batch)
                           .group(:batch_id)
                           .sum(:score_in_batch)
                           .except(nil)
                           .transform_keys { |k| Batch.find(k).number }
                           .sort_by { |_k, v| -v }

    @sorted_users = Score.group(:user_id)
                         .sum(:score_solo)
                         .transform_keys { |k| User.find(k).username }
                         .sort_by { |_k, v| -v }
  end
end
