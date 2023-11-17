# frozen_string_literal: true

module Scores
  class CampusRowComponent < ApplicationComponent
    include ScoresHelper

    with_collection_parameter :campus

    def initialize(campus:, user:)
      @campus = campus
      @user = user
    end
  end
end
