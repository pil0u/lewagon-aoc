# frozen_string_literal: true

module Scores
  class SquadRowComponent < ApplicationComponent
    include ScoresHelper

    with_collection_parameter :squad

    def initialize(squad:, user:)
      @squad = squad
      @user = user

      set_rank_diff
    end

    private

    def set_rank_diff
      @rank_diff = if @squad[:previous_rank] < @squad[:rank]
                     "<i class=\"rank-down\"></i>".html_safe
                   elsif @squad[:previous_rank] == @squad[:rank]
                     "<i class=\"rank-equal\"></i>".html_safe
                   elsif @squad[:previous_rank] > @squad[:rank]
                     "<i class=\"rank-up\"></i>".html_safe
                   end
    end
  end
end
