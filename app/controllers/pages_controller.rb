# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[code_of_conduct faq participation stats welcome]
  before_action :render_countdown, only: %i[code_of_conduct faq participation stats welcome], if: :render_countdown?

  def achievements
    @achievements = Achievement.full_list.to_a
    @user_achievements = current_user.achievements.pluck(:nature)
  end

  def calendar
    user_completions = current_user.completions.group(:day).count
    @advent_days = [
      2,  23, 19, 15, 6,
      14, 10, 1,  22, 18,
      21, 17, 13, 9,  5,
      8,  4,  25, 16, 12,
      20, 11, 7,  3,  24
    ].map do |day|
      {
        parts_solved: user_completions[day] || 0,
        release_time: Time.new(2022, 12, day, 0, 0, 0, "-05:00")
      }
    end

    @next_puzzle_time = Aoc.next_puzzle_time
    @now = Time.now.getlocal("-05:00")
  end

  def code_of_conduct
    @admins = User.admins.pluck(:username)
  end

  def countdown
    render "countdown", layout: false
  end

  def faq; end

  def participation
    users_per_city = City.joins(:users).group(:id).count
    @cities = City.all.map do |city|
      n_participants = users_per_city[city.id] || 0

      {
        slug: city.slug,
        name: city.name,
        size: city.size,
        n_participants:,
        participation_ratio: n_participants / city.size.to_f
      }
    end

    @cities.sort_by! { |city| [city[:participation_ratio] * -1, city[:name]] }
  end

  def setup
    @private_leaderboard = ENV.fetch("AOC_ROOMS").split(",").last
  end

  def stats
    @registered_users = User.count
    @confirmed_users = User.confirmed.count
    @participating_users = User.distinct(:id).joins(:completions).count
    @users_with_snippets = User.distinct(:id).joins(:snippets).count
    @total_snippets = Snippet.count

    @gold_stars = Completion.where(challenge: 2).count
    @silver_stars = Completion.where(challenge: 1).count - @gold_stars

    @daily_completers = Completion.group(:day, :challenge).order(:day, :challenge).count # { [12, 1]: 5, [12, 2]: 8, ... }
                                  .group_by { |day_challenge, _| day_challenge.first }   # { 12: [ [[12, 1], 5], [[12, 2], 8] ], ... }
                                  .map do |day, completers|
                                    {
                                      number: day,
                                      gold_completers: completers.dig(1, 1).to_i,
                                      silver_completers: completers.dig(0, 1).to_i - completers.dig(1, 1).to_i
                                    }
                                  end
    @users_per_star = (@daily_completers.map { |h| h[:gold_completers] + h[:silver_completers] }.max.to_f / 50).ceil
  end

  def welcome
    @total_users = User.count
  end

  private

  def render_countdown
    render "countdown", layout: false
  end

  def render_countdown?
    Time.now.utc < Aoc.launch_time && Rails.env.production? && !ENV["THIS_IS_STAGING"]
  end

  #   ### old

  #   MAGIC_DAYS = [17, 24, 1, 8, 15, 23, 5, 7, 14, 16, 4, 6, 13, 20, 22, 10, 12, 19, 21, 3, 11, 18, 25, 2, 9].freeze

  #   def dashboard
  #     # Time
  #     @now = Time.now.getlocal("-05:00")

  #     now_utc = Time.now.utc
  #     last_api_fetch_utc = State.last.fetch_api_end.utc
  #     @time_since_last_api_fetch = helpers.distance_of_time_in_words(last_api_fetch_utc, now_utc)

  #     @estimated_next_api_fetch = if now_utc < last_api_fetch_utc + 10.minutes
  #                                   helpers.distance_of_time_in_words(last_api_fetch_utc + 10.minutes, now_utc)
  #                                 else
  #                                   "soon™"
  #                                 end

  #     next_puzzle_time = Aoc.next_puzzle_time_from(@now)
  #     @time_to_next_puzzle = helpers.distance_of_time_in_words(@now, next_puzzle_time)

  #     # Event
  #     @aoc_in_progress = Aoc.in_progress?
  #     @year = ENV.fetch("EVENT_YEAR")
  #     @current_open_room = ENV.fetch("AOC_ROOMS").split(",").last
  #     @user_status = current_user.status

  #     # User stats

  #     ## Individual rank & score
  #     @user_score = {
  #       rank: current_user.rank.in_contest,
  #       score: current_user.score.in_contest.to_i,
  #       score_in_batch: current_user.batch_contributions.sum(:points),
  #       score_in_city: current_user.city_contributions.sum(:points)
  #     }
  #     @total_users = User.synced.count

  #     ## Batch rank & score
  #     @user_batch = current_user.batch

  #     if @user_batch
  #       @user_batch_score = { score: @user_batch.batch_score.in_contest.to_i, rank: @user_batch.batch_score.rank }
  #       @total_batches = BatchScore.count
  #     end

  #     ## City rank & score
  #     @user_city = current_user.city

  #     if @user_city
  #       @user_city_score = { score: @user_city.city_score.in_contest.to_i, rank: @user_city.city_score.rank }
  #       @total_cities = CityScore.count
  #     end

  #     # Calendar
  #     @advent_days = MAGIC_DAYS.map { |advent_day| Time.new(2021, 12, advent_day, 0, 0, 0, "-05:00") }

  #     # Today
  #     @today_challenges = {}

  #     [1, 2].each do |challenge|
  #       user_solved = current_user.completions.find_by(day: @now.day, challenge:)

  #       if user_solved
  #         @today_challenges[challenge] = [true, user_solved.point_value.in_contest]
  #       else
  #         last_solved = Completion.actual.where(day: @now.day, challenge:)
  #                                 .order(:rank_solo).last

  #         challenge_score = last_solved ? last_solved.point_value.in_contest - 1 : User.synced.count
  #         @today_challenges[challenge] = [false, challenge_score]
  #       end
  #     end
  #   end

  #   def scoreboard
  #     @anchors = {
  #       "#cities-scoreboard": "Cities scoreboard",
  #       "#user-city-rank": current_user.city&.name,
  #       "#batches-scoreboard": "Batches scoreboard",
  #       "#user-batch-rank": ("Batch ##{current_user.batch.number}" if current_user.batch),
  #       "#solo-scoreboard": "Solo scoreboard",
  #       "#user-rank": current_user.username
  #     }.compact

  #     @ranked_cities = CityScore.joins(:city).left_joins(city: { users: :score }).where("users.synced")
  #                               .order(:rank, "cities.name").distinct
  #                               .select("cities.name AS city_name",
  #                                       Arel.sql("COUNT(*) OVER (PARTITION BY cities.id) AS city_n_users"),
  #                                       Arel.sql("AVG(scores.in_contest) OVER (PARTITION BY cities.id) AS score_average"),
  #                                       "city_scores.in_contest AS city_score",
  #                                       "city_scores.rank AS city_rank")
  #                               .map { |row| row.attributes.symbolize_keys }
  #                               .reject { |h| h[:city_name].nil? }
  #                               .each { |h| h[:city_score] = h[:city_score].to_i }
  #                               .each { |h| h[:score_average] = h[:score_average].ceil }
  #     @max_city_contributors = City.max_contributors

  #     @ranked_batches = BatchScore.joins(:batch).left_joins(batch: { users: :score }).where("users.synced")
  #                                 .order(:rank, "batches.number": :desc).distinct
  #                                 .select("batches.number AS batch_number",
  #                                         Arel.sql("COUNT(*) OVER (PARTITION BY batches.id) AS batch_n_users"),
  #                                         Arel.sql("AVG(scores.in_contest) OVER (PARTITION BY batches.id) AS score_average"),
  #                                         "batch_scores.in_contest AS batch_score",
  #                                         "batch_scores.rank AS batch_rank")
  #                                 .map { |row| row.attributes.symbolize_keys }
  #                                 .reject { |h| h[:batch_number].nil? }
  #                                 .each { |h| h[:batch_score] = h[:batch_score].to_i }
  #                                 .each { |h| h[:score_average] = h[:score_average].ceil }
  #     @max_batch_contributors = Batch.max_contributors

  #     @ranked_users = Score.joins(user: :rank).left_joins(user: %i[batch city]).where("users.synced")
  #                          .order("ranks.in_contest, users.id DESC")
  #                          .select("users.uid AS uid",
  #                                  "users.id AS id",
  #                                  "users.username AS username",
  #                                  "batches.number AS batch",
  #                                  "cities.name AS city", "scores.in_contest AS score_solo", "ranks.in_contest AS rank",
  #                                  "(SELECT COUNT(*) FROM completions co WHERE co.user_id = users.id AND co.challenge = 1) AS silver_stars",
  #                                  "(SELECT COUNT(*) FROM completions co WHERE co.user_id = users.id  AND co.challenge = 2) AS gold_stars")
  #                          .map { |row| row.attributes.symbolize_keys }
  #                          .each { |h| h[:score_solo] = h[:score_solo].to_i }
  #   end

  #   def stats
  #     @gold_stars = Completion.where(challenge: 2).count
  #     @silver_stars = Completion.where(challenge: 1).count - @gold_stars
  #     @total_kitt_signups = User.where(provider: "kitt").count
  #     @total_synced_users = User.synced.count
  #     @total_participating_users = User.distinct(:id).joins(:completions).merge(Completion.actual).count

  #     stars_per_challenge = Completion.actual.group(:day, :challenge).count.sort_by(&:first).to_h
  #     @stars_per_day = stars_per_challenge.group_by { |key, _l| key.first }.transform_values { |star_counts| star_counts.sort_by(&:first).map(&:last) }
  #     # AoC formula for how many users per star
  #     @users_per_star = (stars_per_challenge.map(&:last).max.to_f / 40).ceil
  #   end
end
