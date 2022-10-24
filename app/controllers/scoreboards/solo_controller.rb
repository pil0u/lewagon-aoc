# frozen_string_literal: true

module Scoreboards
  class SoloController
    def show
      @scores = Scores::SoloScores.get
    end
  end
end
