# frozen_string_literal: true

module ApplicationHelper
  def day_css(day, day_of_december)
    # TODO: eager load all scores
    parts_solved = Score.where(user: current_user, day: day).count

    {
      "text-aoc-gray-darker": day_of_december.nil? || day > day_of_december,
      "text-aoc-gray-dark": parts_solved == 0,
      "text-aoc-silver": parts_solved == 1,
      "text-aoc-gold": parts_solved == 2
    }
  end

  def status_css(status)
    {
      "text-wagon-red-light": status == "KO",
      "text-aoc-atmospheric": status == "pending",
      "text-aoc-green": status == "OK"
    }
  end
end
