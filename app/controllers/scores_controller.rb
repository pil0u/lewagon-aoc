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

    @participants = [
      {
        uid: 1,
        rank: 1,
        previous_rank: 12,
        entered_hardcore: false,
        username: "Francisco-Webdeveloper-andMore",
        city_name: "Rio de Janeiro",
        batch_number: 1970,
        squad_name: "This is very long 123456",
        silver_stars: 10,
        gold_stars: 15,
        score: 50 * 2 * 25,
        daily_score: 100
      },
      {
        uid: 6788,
        rank: 2,
        previous_rank: 2,
        entered_hardcore: false,
        username: "pil0u",
        city_name: "Bordeaux",
        batch_number: 343,
        squad_name: "Vuvuzela",
        silver_stars: 3,
        gold_stars: 14,
        score: 1234,
        daily_score: 50
      },
      {
        uid: 12,
        rank: 2,
        previous_rank: 1,
        username: "toto",
        city_name: nil,
        batch_number: nil,
        squad_name: nil,
        silver_stars: 0,
        gold_stars: 0,
        score: 0,
        daily_score: 0
      }
    ]

    add_display_rank(@participants)
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
