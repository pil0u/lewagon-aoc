# frozen_string_literal: true

require "aoc"

module ApplicationHelper
  def day_css(now, advent_day)
    unlocked = now >= Aoc.start_time && advent_day <= now

    # TODO: eager load all scores
    parts_solved = Score.where(user: current_user, day: advent_day.day).count

    {
      "text-aoc-gray-darker": !unlocked,
      "text-aoc-gray-dark": unlocked && parts_solved == 0,
      "text-aoc-silver": unlocked && parts_solved == 1,
      "text-aoc-gold": unlocked && parts_solved == 2
    }
  end

  def status_css(status)
    {
      "text-wagon-red-light": status == "KO",
      "text-aoc-atmospheric": status == "pending",
      "text-aoc-green": status == "OK"
    }
  end

  def ranking_css(index, rank_col: false)
    {
      "text-aoc-gold text-shadow-gold": index == 0,
      "text-aoc-silver text-shadow-silver": index == 1,
      "text-aoc-bronze text-shadow-bronze": index == 2,
      "text-xl": index <= 2 && rank_col,
      strong: index > 2 && rank_col
    }
  end
end
