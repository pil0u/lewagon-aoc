# frozen_string_literal: true

module Stats
  class CitiesController < ApplicationController
    before_action :set_city, only: [:show]

    def show
      @city_mates = @city.users
                         .left_joins(:batch).joins(:city_contributions, :score)
                         .preload(:score, :batch, :city_contributions)
                         .order("rank_in_city").uniq
    end

    private

    def set_city
      @city = City.find_by_slug(params[:slug]) # rubocop:disable Rails/DynamicFindBy
    end
  end
end
