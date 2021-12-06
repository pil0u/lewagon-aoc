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

    @estimated_next_api_fetch = if now_utc < last_api_fetch_utc + 10.minutes
                                  helpers.distance_of_time_in_words(last_api_fetch_utc + 10.minutes, now_utc)
                                else
                                  "soon™"
                                end

    next_puzzle_time = Aoc.next_puzzle_time_from(@now)
    @time_to_next_puzzle = helpers.distance_of_time_in_words(@now, next_puzzle_time)

    # Event
    @aoc_in_progress = Aoc.in_progress?
    @year = ENV["EVENT_YEAR"] || Time.zone.today.year
    @current_open_room = ENV["AOC_ROOMS"].split(",").last
    @user_status = current_user.status

    # User stats

    ## Individual rank & score
    @user_score = {
      rank: current_user.rank.in_contest,
      score: current_user.score.in_contest.to_i,
      score_in_batch: current_user.batch_contributions.sum(:points),
      score_in_city: current_user.city_contributions.sum(:points)
    }
    @total_users = User.synced.count

    ## Batch rank & score
    @user_batch = current_user.batch

    if @user_batch
      @user_batch_score = { score: @user_batch.batch_score.in_contest.to_i, rank: @user_batch.batch_score.rank }
      @total_batches = BatchScore.count
    end

    ## City rank & score
    @user_city = current_user.city

    if @user_city
      @user_city_score = { score: @user_city.city_score.in_contest.to_i, rank: @user_city.city_score.rank }
      @total_cities = CityScore.count
    end

    # Calendar
    @advent_days = MAGIC_DAYS.map { |advent_day| Time.new(2021, 12, advent_day, 0, 0, 0, "-05:00") }
  end

  def scoreboard
    @anchors = {
      "#cities-scoreboard": "Cities scoreboard",
      "#user-city-rank": current_user.city&.name,
      "#batches-scoreboard": "Batches scoreboard",
      "#user-batch-rank": ("Batch ##{current_user.batch.number}" if current_user.batch),
      "#solo-scoreboard": "Solo scoreboard",
      "#user-rank": current_user.username
    }.compact

    @ranked_cities = CityScore.joins(:city).left_joins(city: {users: :score}).where("users.synced")
                              .order(:rank, "cities.name").distinct
                              .select("cities.name AS city_name",
                                      Arel.sql("count(*) OVER (PARTITION BY cities.id) AS city_n_users"),
                                      Arel.sql("avg(scores.in_contest) OVER (PARTITION BY cities.id) AS score_average"),
                                      "city_scores.in_contest AS city_score",
                                      "city_scores.rank AS city_rank")
                              .map { |row| row.attributes.symbolize_keys }
                              .reject { |h| h[:city_name].nil? }
                              .each { |h| h[:city_score] = h[:city_score].to_i }
                              .each { |h| h[:score_average] = h[:score_average].round(1) }
    @max_city_contributors = City.max_contributors

    @ranked_batches = BatchScore.joins(:batch).left_joins(batch: {users: :score}).where("users.synced")
                                .order(:rank, "batches.number": :desc).distinct
                                .select("batches.number AS batch_number",
                                        Arel.sql("count(*) OVER (PARTITION BY batches.id) AS batch_n_users"),
                                        Arel.sql("avg(scores.in_contest) OVER (PARTITION BY batches.id) AS score_average"),
                                        "batch_scores.in_contest AS batch_score",
                                        "batch_scores.rank AS batch_rank")
                                .map { |row| row.attributes.symbolize_keys }
                                .reject { |h| h[:batch_number].nil? }
                                .each { |h| h[:batch_score] = h[:batch_score].to_i }
                              .each { |h| h[:score_average] = h[:score_average].round(1) }
    @max_batch_contributors = Batch.max_contributors

    @ranked_users = Score.joins(user: :rank).left_joins(user: :batch).left_joins(user: :city).where("users.synced")
                         .order("ranks.in_contest, users.id DESC")
                         .select("users.uid AS uid", "users.username AS username", "batches.number AS batch",
                                 "cities.name AS city", "scores.in_contest AS score_solo", "ranks.in_contest AS rank")
                         .map { |row| row.attributes.symbolize_keys }
                         .each { |h| h[:score_solo] = h[:score_solo].to_i }

    @contributor_ids = User.contributors.pluck(:uid)
  end

  def status
    @total_completions = Completion.count
    @total_users = User.count
    @total_rows = Batch.count + City.count + State.count + @total_completions + @total_users
    @total_rows_color = if @total_rows < 8000
                          "text-aoc-green-light"
                        else
                          @total_rows < 9000 ? "text-aoc-gold" : "text-wagon-red"
                        end

    now = Time.now.getlocal("-05:00")
    elapsed_time_seconds = now - Aoc.start_time
    event_duration_seconds = Aoc.end_time - Aoc.start_time
    # event_duration_seconds = Time.new(2022, 1, 7, 10, 0, 0, "UTC") - Aoc.start_time

    # Basic linear projection
    @projected_completions = @total_completions * event_duration_seconds / elapsed_time_seconds
    @projected_total = @total_rows - @total_completions + @projected_completions
  end
end
