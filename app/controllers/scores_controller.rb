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

    scores = Scores::SoloScores.get
    presenter = Scores::SoloRanksPresenter.new(scores)

    @participants = presenter.ranks

    add_display_rank(@participants)

    # @participants = [
    #   {
    #     uid: 1,                                     # uid
    #     rank: 1,                                    # TBD
    #     previous_rank: 12,                          # TBD
    #     username: "Francisco-Webdeveloper-andMore", # username
    #     city_name: "Rio de Janeiro",                # JOIN cities ON cities.id = users.city_id (cities.name)
    #     batch_number: 1970,                         # JOIN batches ON batches.id = users.batch_id (batches.number)
    #     squad_name: "This is very long 123456",     # JOIN squads ON squads.id = users.squad_id (squads.name)
    #     silver_stars: 10,                           # TBD
    #     gold_stars: 15,                             # TBD
    #     score: 500 * 2 * 25,                        # TBD
    #     daily_score: 124                            # TBD
    #   },
    #   {
    #     uid: 6788,
    #     rank: 2,
    #     previous_rank: 2,
    #     username: "pil0u",
    #     city_name: "Bordeaux",
    #     batch_number: 343,
    #     squad_name: "Vuvuzela",
    #     silver_stars: 3,
    #     gold_stars: 14,
    #     score: 1234,
    #     daily_score: 18
    #   },
    #   {
    #     uid: 12,
    #     rank: 2,
    #     previous_rank: 1,
    #     username: "toto",
    #     city_name: nil,
    #     batch_number: nil,
    #     squad_name: nil,
    #     silver_stars: 0,
    #     gold_stars: 0,
    #     score: 0,
    #     daily_score: 0
    #   }
    # ]
  end

  def solo
    session[:last_score_page] = "solo"

    scores = Scores::SoloScores.get
    presenter = Scores::SoloRanksPresenter.new(scores)

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
