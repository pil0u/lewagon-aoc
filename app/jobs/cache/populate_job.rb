# frozen_string_literal: true

class Cache::PopulateJob < ApplicationJob
  queue_as :default

  def perform
    # We don't need to do anything with the values, we're just populating the caches
    Scores::SoloScores.get
    Scores::InsanityScores.get
    Scores::CityScores.get
    Scores::SquadScores.get
  end
end
