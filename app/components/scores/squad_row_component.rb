# frozen_string_literal: true

class Scores::SquadRowComponent < ApplicationComponent
  include ScoresHelper

  with_collection_parameter :squad

  def initialize(squad:, user:)
    @squad = squad
    @user = user

    set_rank_diff
  end

  private

  def set_rank_diff
    @rank_diff = case
                 when @squad[:old_rank] < @squad[:rank] then "<i class=\"rank-down\"></i>".html_safe
                 when @squad[:old_rank] == @squad[:rank] then "<i class=\"rank-equal\"></i>".html_safe
                 when @squad[:old_rank] > @squad[:rank] then "<i class=\"rank-up\"></i>".html_safe
                 end
  end
end
