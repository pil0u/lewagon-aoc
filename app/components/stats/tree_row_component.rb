# frozen_string_literal: true

module Stats
  class TreeRowComponent < ApplicationComponent
    with_collection_parameter :day

    def initialize(day:, users_per_star:)
      @day = day
      @users_per_star = users_per_star
    end
  end
end
