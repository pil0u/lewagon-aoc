# frozen_string_literal: true

module Scores
  class UserRowComponent < ApplicationComponent
    include ScoresHelper

    with_collection_parameter :participant

    def initialize(participant:, user:, extended: false)
      @participant = participant
      @user = user
      @extended = extended
    end
  end
end
