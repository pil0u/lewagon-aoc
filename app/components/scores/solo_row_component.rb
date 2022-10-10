# frozen_string_literal: true

module Scores
  class SoloRowComponent < ApplicationComponent
    include ScoresHelper

    with_collection_parameter :participant

    def initialize(participant:, user:, hardcore:)
      @participant = participant
      @user = user
      @hardcore = hardcore
    end
  end
end
