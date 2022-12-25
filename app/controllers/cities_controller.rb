# frozen_string_literal: true

class CitiesController < ApplicationController
  def show
    @city = City.find_by_slug(params[:slug]) # rubocop:disable Rails/DynamicFindBy

    casual_scores = Scores::SoloScores.get
    casual_presenter = Scores::UserScoresPresenter.new(casual_scores)
    casual_participants = casual_presenter.ranks
    squad_user_uids = @city.users.pluck(:uid).map(&:to_i)
    @city_users = casual_participants.select { |p| p[:uid].in? squad_user_uids }
                                     .sort_by { |p| p[:score] * -1 }
    compute_ranks_from_score(@city_users)

    city_scores = Scores::CityScores.get
    city_presenter = Scores::CityScoresPresenter.new(city_scores)
    cities = city_presenter.ranks
    @city_stats = cities.find { |h| h[:id] == @city.id }
    # TODO: remove when implemented
    @city_stats[:silver_stars] = @city_users.sum { |h| h[:silver_stars] }
    @city_stats[:gold_stars] = @city_users.sum { |h| h[:gold_stars] }
  end

  private

  # This method computes the proper :rank and adds a :display_rank boolean
  # attribute which tells whether the rank should be displayed or hidden because
  # of a tie with the previous entity
  def compute_ranks_from_score(array)
    [{}, *array].each_cons(2).map do |elem_a, elem_b|
      if elem_a == {}
        elem_b[:rank] = 1
        elem_b[:display_rank] = true
      elsif elem_b[:score] == elem_a[:score]
        elem_b[:rank] = elem_a[:rank]
        elem_b[:display_rank] = false
      else
        elem_b[:rank] = elem_a[:rank] + 1
        elem_b[:display_rank] = true
      end
    end
  end
end
