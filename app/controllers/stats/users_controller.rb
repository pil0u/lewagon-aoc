# frozen_string_literal: true

module Stats
  class UsersController < ApplicationController
    before_action :set_user, only: [:show]

    def show
      @gold_stars = @user.completions.actual.where(challenge: 2).count
      @silver_stars = @user.completions.actual.where(challenge: 1).count - @gold_stars

      @score = @user.score.in_contest.to_i
      @rank = @user.rank.in_contest
      @total_users = User.synced.count

      if @user.batch
        @batch_score = @user.batch.batch_score.in_contest.to_i
        @batch_rank = @user.batch.batch_score.rank
        @total_batches = BatchScore.count
        @batch_contribution = @user.batch_contributions.sum(:points).to_i
      end

      if @user.city
        @city_score = @user.city.city_score.in_contest.to_i
        @city_rank = @user.city.city_score.rank
        @total_cities = CityScore.count
        @city_contribution = @user.city_contributions.sum(:points).to_i
      end

      @completions = @user.completions.actual.left_joins(:point_value, :completion_rank)
                          .select(
                            :day,
                            :challenge,
                            "completion_ranks.in_contest AS rank",
                            "point_values.in_contest AS score",
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
