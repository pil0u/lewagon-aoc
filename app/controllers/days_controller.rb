# frozen_string_literal: true

class DaysController < ApplicationController
  def show
    @day = params[:day].to_i
    daily_completions = Completion.includes(:user).where(day: @day)

    completions = daily_completions.group(:challenge).count
    @gold_stars = completions[2].to_i 
    @silver_stars = completions[1].to_i - @gold_stars

    @snippets_part_one = Snippet.where(day: @day, challenge: 1).count
    @snippets_part_two = Snippet.where(day: @day, challenge: 2).count
    @solved_part_one = daily_completions.find_by(user: current_user, challenge: 1)
    @solved_part_two = daily_completions.find_by(user: current_user, challenge: 2)

    attributes = %i(user_id username challenge duration)
    user_completions = daily_completions.pluck(*attributes).map { |completion| attributes.zip(completion).to_h }
    user_scores = Scores::SoloPoints.get
                                    .select { |score| score[:day] == @day }
                                    .group_by { |score| score[:user_id] }
                                    .map { |user_id, scores| [user_id, scores.map { |score| score[:score]}.sum] }
                                    .to_h

    @users = user_scores.map do |user_id, score|
      {
        username: user_completions.find { |completion| completion[:user_id] == user_id }.dig(:username),
        part_1: user_completions.find { |completion| completion[:user_id] == user_id && completion[:challenge] == 1 }&.dig(:duration),
        part_2: user_completions.find { |completion| completion[:user_id] == user_id && completion[:challenge] == 2 }&.dig(:duration),
        score:
      }
    end.sort_by { |user_score| [user_score[:score] * -1, user_score[:part_2], user_score[:part_1]] }
  end
end
