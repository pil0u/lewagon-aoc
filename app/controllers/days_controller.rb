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

    # @part_1 = Puzzle::DIFFICULTY_LEVELS[@puzzle&.difficulty_part_1] || Puzzle::DEFAULT_DIFFICULTY
    # @part_2 = Puzzle::DIFFICULTY_LEVELS[@puzzle&.difficulty_part_2] || Puzzle::DEFAULT_DIFFICULTY
    # @difficulty_title = <<~TEXT
    #   Estimated difficulty (experimental)
    #   Part 1: #{@part_1[:difficulty]} #{@part_1[:colour]}
    #   Part 2: #{@part_2[:difficulty]} #{@part_2[:colour]}
    # TEXT
  end

  private

  def part_is_unlocked?(challenge)
    # Taken from AllowedToSeeSolutionsConstraint
    current_user.solved?(@day, challenge) || Completion.where(day: @day, challenge:).count >= 5
  end
end
