# frozen_string_literal: true

module ScoresHelper
  def rank_css(rank)
    {
      "text-gold": rank == 1,
      "text-silver": rank == 2,
      "text-bronze": rank == 3,
      "text-xl": rank <= 3,
      strong: rank > 3
    }
  end

  def rank_evolution_css(previous_rank, current_rank)
    {
      "rank-down": previous_rank < current_rank,
      "rank-equal": previous_rank == current_rank,
      "rank-up": previous_rank > current_rank
    }
  end

  def scores_path
    "/scores/#{session[:last_score_page] ||= 'squads'}"
  end
end
