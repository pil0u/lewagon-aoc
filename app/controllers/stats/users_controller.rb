# frozen_string_literal: true

module Stats
  class UsersController < ApplicationController
    before_action :set_user, only: [:show]

    def show
      @gold_stars = @user.completions.actual.where(challenge: 2).count
      @silver_stars = @user.completions.actual.where(challenge: 1).count - @gold_stars

      @score = @user.score.in_contest
      @rank = @user.score.rank_in_contest
      @total_users = User.synced.count

      if @user.batch
        @batch_score = @user.batch.score.in_contest
        @batch_rank = @user.batch.score.rank_in_contest
        @total_batches = BatchScore.count
        @batch_contribution = @user.batch_contributions.sum(:in_contest)
      end

      if @user.city
        @city_score = @user.city.score.in_contest
        @city_rank = @user.city.score.rank_in_contest
        @total_cities = CityScore.count
        @city_contribution = @user.city_contributions.sum(:in_contest)
      end

      @latest_day = Aoc.in_progress? ? Time.now.getlocal("-05:00").day : 25

      @completions = @user.points.completed.left_joins(:completion)
                          .select(
                            :day,
                            :challenge,
                            "rank_in_contest AS rank",
                            "in_contest AS score",
                            "completion_unix_time AS timestamp"
                          )
                          .map(&:attributes).map(&:symbolize_keys)
                          .index_by { |attrs| [attrs[:day], attrs[:challenge]] }
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
