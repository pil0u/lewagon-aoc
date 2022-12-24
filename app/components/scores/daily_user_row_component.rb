# frozen_string_literal: true

module Scores
  class DailyUserRowComponent < ApplicationComponent
    include ApplicationHelper

    with_collection_parameter :participant

    def initialize(participant:, user:)
      @participant = participant
      @user = user
    end
  end
end
