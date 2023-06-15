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

    scores = Scores::UserDayScores.get.select { |score| score[:day] == @day }
    presenter = Scores::DayScoresPresenter.new(scores)

    @participants = presenter.scores
  end
end
