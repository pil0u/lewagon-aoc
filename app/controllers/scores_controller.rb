# frozen_string_literal: true

class ScoresController < ApplicationController
  def cities
    session[:last_score_page] = "cities"
  end

  def insanity
    session[:last_score_page] = "insanity"
  end

  def solo
    session[:last_score_page] = "solo"
  end

  def squads
    session[:last_score_page] = "squads"
  end
end
