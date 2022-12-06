# frozen_string_literal: true

class DaysController < ApplicationController
  def show
    @day = params[:day].to_i
    daily_completions = Completion.includes(:user).where(day: @day)

    completions = daily_completions.group(:challenge).count
    @gold_stars = completions[2].to_i
    @silver_stars = completions[1].to_i - @gold_stars

    @solved_part_one = current_user.solved?(@day, 1)
    @solved_part_two = current_user.solved?(@day, 2)
    @snippets_part_one = Snippet.where(day: @day, challenge: 1).count
    @snippets_part_two = Snippet.where(day: @day, challenge: 2).count

    attributes = %i[user_id username challenge duration]
    user_completions = daily_completions.pluck(*attributes).map { |completion| attributes.zip(completion).to_h }
    @users = Scores::SoloPoints.get
                               .select { |score| score[:day] == @day }
                               .group_by { |score| score[:user_id] }
                               .transform_values { |scores| scores.sum { |score| score[:score] } }
                               .map do |user_id, score|
      {
        username: user_completions.find { |completion| completion[:user_id] == user_id }[:username],
        part_1: user_completions.find { |completion| completion[:user_id] == user_id && completion[:challenge] == 1 }&.dig(:duration),
        part_2: user_completions.find { |completion| completion[:user_id] == user_id && completion[:challenge] == 2 }&.dig(:duration),
        score:
      }
    end

    @users.sort_by! { |user| [user[:score] * -1, user[:part_2].nil? ? user[:part_1] : user[:part_2], user[:part_1]] }
  end
end
