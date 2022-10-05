# frozen_string_literal: true

module Scores
  class SquadRowComponent < ApplicationComponent
    include ScoresHelper

    with_collection_parameter :squad

    def initialize(squad:, user:)
      @squad = squad
      @user = user
    end
  end
end
