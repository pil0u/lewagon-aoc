# frozen_string_literal: true

class ScoresController < ApplicationController
  def cities
    session[:last_score_page] = "cities"

    @cities = [
      {
        id: 4,
        slug: "rio-de-janeiro",
        name: "Rio de Janeiro",
        total_members: 25,
        previous_rank: 3,
        rank: 1,
        score: 1235,
        daily_contributors_part_1: 23,
        daily_contributors_part_2: 23,
        top_contributors: 12
      },
      {
        id: 9,
        slug: "brussels-⭐",
        name: "Brussels ⭐",
        total_members: 42,
        previous_rank: 1,
        rank: 2,
        score: 1245,
        daily_contributors_part_1: 8,
        daily_contributors_part_2: 6,
        top_contributors: 17
      }
    ]

    add_display_rank(@cities)
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
        total_members: 3,
        previous_rank: 1,
        rank: 1,
        score: 1234,
        daily_score: 200
      },
      {
        id: 23,
        name: "The Squad name is long",
        total_members: 4,
        previous_rank: 3,
        rank: 4,
        score: 1000,
        daily_score: 25
      },
      {
        id: 12,
        name: "This is the maximum lgth",
        total_members: 4,
        previous_rank: 2,
        rank: 2,
        score: 25 * 2 * 50 * 4,
        daily_score: 150
      },
      {
        id: 6,
        name: "Yolo squad",
        total_members: 4,
        previous_rank: 4,
        rank: 2,
        score: 1200,
        daily_score: 124
      },
      {
        id: 5,
        name: "Yolo squad 3",
        total_members: 4,
        previous_rank: 6,
        rank: 5,
        score: 1200,
        daily_score: 32
      }
    ].sort_by! { |squad| squad[:rank] }

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
