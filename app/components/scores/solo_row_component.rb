# frozen_string_literal: true

class Scores::SoloRowComponent < ApplicationComponent
    include ScoresHelper

    with_collection_parameter :participant

    def initialize(participant:, user:)
      @participant = participant
      @user = user
    end
end
