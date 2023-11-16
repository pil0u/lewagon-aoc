# frozen_string_literal: true

module Scores
  class CityRowComponent < ApplicationComponent
    include ScoresHelper

    with_collection_parameter :city

    def initialize(city:, user:)
      @campus = city
      @user = user
    end
  end
end
