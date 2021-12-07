# frozen_string_literal: true

module Stats
  class UsersController < ApplicationController
    before_action :set_user, only: [:show]
    def show
      @total_stars = @user.completions.actual.count
      @score = @user.score.in_contest.to_i
      if @user.batch
        @batch_score = @user.batch.batch_score.in_contest.to_i
        @batch_contribution = @user.batch_contributions.sum(:points).to_i
      end
      if @user.city
        @city_score = @user.city.city_score.in_contest.to_i
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
