# frozen_string_literal: true

module Stats
  class CitiesController < ApplicationController
    before_action :set_city, only: [:show]

    def show
      @city_mates = @city.users
        .left_joins(:batch).joins(:score, :rank).preload(:score, :rank, :batch)
        .order('ranks.in_city')
    end

    private

    def set_city
      @city = City.find_by_slug(params[:slug])
    end
  end
end
