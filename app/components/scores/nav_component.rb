# frozen_string_literal: true

module Scores
  class NavComponent < ApplicationComponent
    def initialize
      @last_score_page = session[:last_score_page] || "squads"
    end
  end
end
