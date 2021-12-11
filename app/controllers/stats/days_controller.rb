# frozen_string_literal: true

module Stats
  class DaysController < ApplicationController
    def show
      @number = params[:number].to_i

      current_user = User.find(122)

      completions = current_user.completions.actual.includes(:completion_rank, :point_value)
      day_completions = Completion.actual.joins(:point_value).where(day: @number)
      @completion_1 = completions.find_by(day: @number, challenge: 1)
      @remaining_points_1 = @completion_1 ? 0 : day_completions.where(challenge: 1).minimum(:in_contest) - 1
      @completion_2 = completions.find_by(day: @number, challenge: 2)
      @remaining_points_2 = @completion_2 ? 0 : day_completions.where(challenge: 2).minimum(:in_contest) - 1

      @batch = current_user.batch
      if @batch
        points = @batch.batch_points
        @batch_score_1 = points.find_by(day: @number, challenge: 1)
        @batch_score_2 = points.find_by(day: @number, challenge: 2)
      end
      @max_batch_contributors = Batch.max_contributors

      @city = current_user.city
      if @city
        points = @city.city_points
        @city_score_1 = points.find_by(day: @number, challenge: 1)
        @city_score_2 = points.find_by(day: @number, challenge: 2)
      end
      @max_city_contributors = City.max_contributors
    end
  end
end
