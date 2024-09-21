# frozen_string_literal: true

class ScoresController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[insanity]

  def campuses
    session[:last_score_page] = "campuses"

    scores = Scores::CityScores.get
    presenter = Scores::CityScoresPresenter.new(scores)

    @campuses = presenter.get

    add_display_rank(@campuses)
  end

  def insanity
    session[:last_score_page] = "insanity"

    scores = Scores::InsanityScores.get
    presenter = Scores::UserScoresPresenter.new(scores)

    @participants = presenter.get

    add_display_rank(@participants)
  end

  def solo
    session[:last_score_page] = "solo"

    scores = Scores::SoloScores.get
    presenter = Scores::UserScoresPresenter.new(scores)

    @participants = presenter.get

    add_display_rank(@participants)
  end

  def squads
    session[:last_score_page] = "squads"

    scores = Scores::SquadScores.get
    presenter = Scores::SquadScoresPresenter.new(scores)

    @squads = presenter.get

    add_display_rank(@squads)
  end

  private

  # This method adds a :display_rank boolean attribute which tells whether the
  # rank should be displayed or hidden because of a tie with the previous entity
  def add_display_rank(array)
    [{}, *array].each_cons(2).map do |elem_a, elem_b|
      elem_b[:display_rank] = (elem_a[:rank] != elem_b[:rank])
    end
  end
end
