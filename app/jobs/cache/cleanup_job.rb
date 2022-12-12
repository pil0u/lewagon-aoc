# frozen_string_literal: true

module Cache
  class CleanupJob < ApplicationJob
    queue_as :default

    def perform
      [
        Cache::SoloPoint, Cache::SoloScore,
        Cache::InsanityPoint, Cache::InsanityScore,
        Cache::SquadPoint, Cache::SquadScore,
        Cache::CityPoint, Cache::CityScore
      ].each do |cache_model|
        Cache::Clean.call(cache_model)
      end
    end
  end
end
