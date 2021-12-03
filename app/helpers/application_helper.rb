# frozen_string_literal: true

require "aoc"

module ApplicationHelper
  def day_css(now, advent_day)
    unlocked = now >= Aoc.start_time && advent_day <= now

    # TODO: eager load all scores
    parts_solved = Completion.where(user: current_user, day: advent_day.day).count

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

  def ranking_css(rank, rank_col: false)
    {
      "text-aoc-gold text-shadow-gold": rank == 1,
      "text-aoc-silver text-shadow-silver": rank == 2,
      "text-aoc-bronze text-shadow-bronze": rank == 3,
      "text-xl": rank <= 3 && rank_col,
      strong: rank > 3 && rank_col
    }
  end
end
