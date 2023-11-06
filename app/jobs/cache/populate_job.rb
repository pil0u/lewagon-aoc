# frozen_string_literal: true

module Cache
  class PopulateJob < ApplicationJob
    queue_as :default

    def perform
      # We don't need to do anything with the values, we're just populating the caches
      Scores::SoloScores.get
      Scores::InsanityScores.get
      Scores::CityScores.get
      Scores::SquadScores.get
      Scores::UserDayScores.get
    end
  end
end
