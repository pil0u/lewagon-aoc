# frozen_string_literal: true

module Scores
  class DailyUserRowComponent < ApplicationComponent
    include ApplicationHelper

    with_collection_parameter :participant

    def initialize(participant:, user:, colorize_hardcore: false)
      @participant = participant
      @user = user
      @colorize_hardcore = colorize_hardcore
    end
  end
end
