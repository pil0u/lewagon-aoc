# frozen_string_literal: true

class ScoresController < ApplicationController
  def cities
    session[:last_score_page] = "cities"

    scores = Scores::CityScores.get
    presenter = Scores::CityRanksPresenter.new(scores)

    @cities = presenter.ranks

    add_display_rank(@cities)
  end

  def insanity
    session[:last_score_page] = "insanity"

    scores = Scores::InsanityScores.get
    presenter = Scores::UserRanksPresenter.new(scores)

    @participants = presenter.ranks
    @participants.select! { |participant| participant[:entered_hardcore] }

    add_display_rank(@participants)
  end

  def solo
    session[:last_score_page] = "solo"

    scores = Scores::SoloScores.get
    presenter = Scores::UserRanksPresenter.new(scores)

    @participants = presenter.ranks

    add_display_rank(@participants)
  end

  def squads
    session[:last_score_page] = "squads"

    scores = Scores::SquadScores.get
    presenter = Scores::SquadRanksPresenter.new(scores)

    @squads = presenter.ranks

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
