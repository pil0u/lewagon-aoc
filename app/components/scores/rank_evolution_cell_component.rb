# frozen_string_literal: true

module Scores
  class RankEvolutionCellComponent < ApplicationComponent
    def initialize(previous_rank:, current_rank:)
      @previous_rank = previous_rank
      @current_rank = current_rank

      set_icon_class
    end

    private

    def set_icon_class
      return if @previous_rank.blank?

      @icon_class = "rank-down" if @previous_rank < @current_rank
      @icon_class = "rank-equal" if @previous_rank == @current_rank
      @icon_class = "rank-up" if @previous_rank > @current_rank
    end
  end
end
