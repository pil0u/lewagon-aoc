# frozen_string_literal: true

class Scores::CityRowComponent < ApplicationComponent
    include ScoresHelper

    with_collection_parameter :city

    def initialize(city:, user:)
      @city = city
      @user = user
    end
end
