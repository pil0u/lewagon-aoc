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

    @users = Scores::UserDayScores.get
      .select { |score| score[:day] == @day }
      .map do |score|
        user = User.find(score[:user_id])
        {
          score: score[:score],
          username: user.username,
          part_1: Completion.find_by(id: score[:part_1_completion_id])&.duration,
          part_2: Completion.find_by(id: score[:part_2_completion_id])&.duration,
        }
      end

    @users.sort_by! { |user| [user[:score] * -1, user[:part_2].nil? ? user[:part_1] : user[:part_2], user[:part_1]] }
  end
end
