# frozen_string_literal: true

module Buddies
  class GenerateDailyPairsJob < ApplicationJob
    queue_as :default

    def perform(day)
      @day = day

      if Buddy.exists?(day:)
        Rails.logger.info "Daily pairs already exist for day #{day}"
        return
      end

      retrieve_users_with_slack_linked
      handle_odd_number_of_users
      generate_possible_pairs_of_buddies

      @possible_pairs.shuffle!

      pick_valid_pairs_of_buddies
      handle_unpaired_users

      insert_generated_buddies
    end

    private

    def retrieve_users_with_slack_linked
      @user_ids = User.slack_linked.where(synced: true).order(:id).pluck(:id)
    end

    def handle_odd_number_of_users
      @user_ids.pop if @user_ids.size.odd?
    end

    def generate_possible_pairs_of_buddies
      all_pairs = @user_ids.combination(2).to_set
      past_buddies = Buddy.pluck(:id_1, :id_2).to_set

      @possible_pairs = (all_pairs - past_buddies).to_a
    end

    def pick_valid_pairs_of_buddies
      @users_to_match = Set.new(@user_ids)
      @buddies = []

      # Iterate once over possible pairs to find matches
      @possible_pairs.each do |pair|
        # If a pair contains two available IDs, it's a match!
        if pair.all? { |id| @users_to_match.include?(id) }
          @buddies << pair
          pair.each { |id| @users_to_match.delete(id) }
        end
      end
    end

    def handle_unpaired_users
      @buddies += @users_to_match.to_a.shuffle.each_slice(2).to_a
    end

    def insert_generated_buddies
      Buddy.insert_all!(@buddies.map { |a, b| { day: @day, id_1: a, id_2: b } })
      Rails.logger.info "Buddies successfully generated for day #{@day}"
    end
  end
end
