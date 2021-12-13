# frozen_string_literal: true

module Stats
  class CitiesController < ApplicationController
    before_action :set_city, only: [:show]

    def show
      @city_mates = @city.users
                         .left_joins(:batch).joins(:score, :rank).preload(:score, :rank, :batch)
                         .order("ranks.in_city")

      contributors_per_challenge = Completion.actual.left_joins(user: :city).where("city_id = ?", @city.id).group(:day, :challenge).count.to_h
      @daily_contributors = contributors_per_challenge.group_by { |key, _l| key.first }.transform_values { |contributors_counts| contributors_counts.sort_by(&:first).map(&:last) }

      @latest_day = Aoc.in_progress? ? Time.now.getlocal("-05:00").day : 25

      @max_contributors = City.max_contributors
    end

    private

    def set_city
      @city = City.find_by_slug(params[:slug]) # rubocop:disable Rails/DynamicFindBy
    end
  end
end
