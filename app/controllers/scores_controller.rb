# frozen_string_literal: true

class ScoresController < ApplicationController
  def index
    session[:last_score_path] ||= "squads"
    redirect_to "/scores/#{session[:last_score_path]}"
  end

  def cities
    session[:last_score_path] = "cities"
  end

  def insanity
    session[:last_score_path] = "insanity"
  end

  def solo
    session[:last_score_path] = "solo"
  end

  def squads
    session[:last_score_path] = "squads"
  end
end
