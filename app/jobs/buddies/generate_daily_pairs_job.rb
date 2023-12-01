# frozen_string_literal: true

# rubocop:disable Metrics/CyclomaticComplexity

module Buddies
  class GenerateDailyPairsJob < ApplicationJob
    queue_as :default

    def perform
      day = Aoc.event_timezone.now.day

      # # Ignore if daily buddies already exist
      # if Buddy.where(day:).count > 0
      #   Rails.logger.info "Daily pairs already exist for day #{day}"
      #   return
      # end

      # The feature is available only for confirmed users
      user_ids = (0..11).to_a
      # user_ids = User.confirmed.order(:id).pluck(:id)

      # Remove the last user if there are an odd number of users
      user_ids.pop if user_ids.size.odd?

      # Generate all possible pairs
      all_pairs = user_ids.combination(2).to_a

      byebug

      past_buddies = Buddy.pluck(:id_1, :id_2).to_set
      all_pairs -= past_buddies

      all_pairs.shuffle!

      users_to_match = Set.new(user_ids)
      buddies = []

      # We iterate over all possible pairs
      all_pairs.each do |pair|
        # If a pair contains two available IDs, it's a match!
        if pair.all? { |id| users_to_match.include?(id) }
          buddies << pair
          pair.each { |id| users_to_match.delete(id) }
        end
      end

      buddies.map! { |a, b| { day:, id_1: a, id_2: b } }
      Buddy.insert_all! buddies
    end
  end
end
