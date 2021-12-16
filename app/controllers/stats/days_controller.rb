# frozen_string_literal: true

module Stats
  class DaysController < ApplicationController
    def show
      @number = params[:number].to_i

      setup_dashboard
      setup_scoreboards
    end

    private

    def setup_dashboard
      scores = DayScore.where(day: @number).preload(:first_completion, :second_completion)
      @day_points = UserPoint.where(day: @number)
      @last_score_1 = @day_points.completed.where(challenge: 1).minimum(:in_contest)
      @last_score_2 = @day_points.completed.where(challenge: 2).minimum(:in_contest)

      current_user = User.find(122)

      @score = scores.find_by(user: current_user)

      @completion_1 = @score.first_completion
      @user_points_1 = @day_points.find_by(challenge: 1)
      @remaining_points_1 = @completion_1 ? 0 : @last_score_1 - 1
      @completion_2 = @score.second_completion
      @user_points_2 = @day_points.find_by(challenge: 2)
      @remaining_points_2 = @completion_2 ? 0 : @last_score_2 - 1

      @batch = current_user.batch
      if @batch
        points = @batch.points

        @batch_score_1 = points.find_by(day: @number, challenge: 1)
        @batch_remaining_points_1 = @batch_score_1.complete ?  0 : (@last_score_1 * @batch_score_1.remaining_contributions) - (1..@batch_score_1.remaining_contributions).sum

        @batch_score_2 = points.find_by(day: @number, challenge: 2)
        @batch_remaining_points_2 = @batch_score_2.complete ?  0 : (@last_score_2 * @batch_score_2.remaining_contributions) - (1..@batch_score_2.remaining_contributions).sum
      end
      @max_batch_contributors = Batch.max_contributors

      @city = current_user.city
      if @city
        points = @city.points
        day_city_points = CityPoint.where(day: @number)

        @city_score_1 = points.find_by(day: @number, challenge: 1)
        @city_remaining_points_1 = @city_score_1.complete ?  0 : (@last_score_1 * @city_score_1.remaining_contributions) - (1..@city_score_1.remaining_contributions).sum

        @city_score_2 = points.find_by(day: @number, challenge: 2)
        @city_remaining_points_2 = @city_score_2.complete ?  0 : (@last_score_2 * @city_score_2.remaining_contributions) - (1..@city_score_2.remaining_contributions).sum
      end
      @max_city_contributors = City.max_contributors
    end

    def setup_scoreboards
      @ranked_cities = CityDayScore.joins(:city).left_joins(city: { users: :day_scores })
        .merge(User.synced).merge(CityDayScore.where(day: @number))
        .order(:rank_in_contest, "cities.name").distinct
        .select("cities.name AS city_name",
          Arel.sql("COUNT(*) OVER (PARTITION BY cities.id) AS city_n_users"),
          Arel.sql("AVG(day_scores.in_contest) FILTER (WHERE day_scores.day = city_day_scores.day) OVER (PARTITION BY cities.id) AS score_average"),
          "city_day_scores.in_contest AS city_score",
          "city_day_scores.rank_in_contest AS city_rank")
        .map { |row| row.attributes.symbolize_keys }
        .reject { |h| h[:city_name].nil? }
        .each { |h| h[:score_average] = h[:score_average].ceil }
      @max_city_contributors = City.max_contributors

      @ranked_batches = BatchDayScore.joins(:batch).left_joins(batch: { users: :day_scores })
        .merge(User.synced).merge(BatchDayScore.where(day: @number))
        .order(:rank_in_contest, "batches.number": :desc).distinct
        .select("batches.number AS batch_number",
          Arel.sql("COUNT(*) OVER (PARTITION BY batches.id) AS batch_n_users"),
          Arel.sql("AVG(day_scores.in_contest) FILTER (WHERE day_scores.day = batch_day_scores.day) OVER (PARTITION BY batches.id) AS score_average"),
          "batch_day_scores.in_contest AS batch_score",
          "batch_day_scores.rank_in_contest AS batch_rank")
        .map { |row| row.attributes.symbolize_keys }
        .reject { |h| h[:batch_number].nil? }
        .each { |h| h[:score_average] = h[:score_average].ceil }
      @max_batch_contributors = Batch.max_contributors

      @ranked_users = DayScore.joins(:user).left_joins(:batch, :city).merge(User.synced)
        .merge(User.synced).merge(DayScore.where(day: @number))
        .order("rank_in_contest, users.id DESC")
        .select("users.uid AS uid",
          "users.id AS id",
          "users.username AS username",
          "batches.number AS batch",
          "cities.name AS city", "day_scores.in_contest AS score_solo", "rank_in_contest AS rank",
          "first_completion_id IS NOT NULL AS silver_star",
          "second_completion_id IS NOT NULL AS gold_star")
        .map { |row| row.attributes.symbolize_keys }
        .each { |h| h[:score_solo] = h[:score_solo].to_i }
    end
  end
end
