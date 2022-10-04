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

    @squads = [
      {
        id: 43,
        name: "The Squad 1",
        n_coders: 3,
        old_rank: 1,
        rank: 1,
        score: 1234
      },
      {
        id: 23,
        name: "The Squad name is long",
        n_coders: 4,
        old_rank: 3,
        rank: 4,
        score: 1000
      },
      {
        id: 12,
        name: "This is the maximum lgth",
        n_coders: 4,
        old_rank: 2,
        rank: 2,
        score: 25 * 2 * 50 * 4
      },
      {
        id: 6,
        name: "Yolo squad",
        n_coders: 4,
        old_rank: 4,
        rank: 2,
        score: 1200
      },
      {
        id: 5,
        name: "Yolo squad 3",
        n_coders: 4,
        old_rank: 6,
        rank: 5,
        score: 1200
      }
    ].sort_by! { |squad| squad[:rank] }

    # For each squad, add the information to display its rank or not in case of tie
    [{}, *@squads].each_cons(2).map do |squad_a, squad_b|
      squad_b[:display_rank] = (squad_a[:rank] != squad_b[:rank])
    end
  end
end
