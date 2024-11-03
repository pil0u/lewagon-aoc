# frozen_string_literal: true

class DaysController < ApplicationController
  def show
    @day = params[:day].to_i

    @daily_buddy = Buddy.of_the_day(current_user)

    daily_completions = Completion.includes(:user).where(day: @day)
    completions = daily_completions.group(:challenge).count
    @gold_stars = completions[2].to_i
    @silver_stars = completions[1].to_i - @gold_stars

    @part_one_is_unlocked = part_is_unlocked?(1)
    @part_two_is_unlocked = part_is_unlocked?(2)
    @snippets_part_one = Snippet.where(day: @day, challenge: 1).count
    @snippets_part_two = Snippet.where(day: @day, challenge: 2).count

    scores = Scores::UserDayScores.get.select { |score| score[:day] == @day }
    presenter = Scores::DayScoresPresenter.new(scores)

    @participants = presenter.get

    @puzzle = Puzzle.by_date(Aoc.begin_time.change(day: @day))
  end

  private

  def part_is_unlocked?(challenge)
    # Taken from AllowedToSeeSolutionsConstraint
    current_user.solved?(@day, challenge) || Completion.where(day: @day, challenge:).count >= 5
  end
end
