# frozen_string_literal: true

class CampusesController < ApplicationController
  def show
    @campus = City.find_by_slug(params[:slug]) # rubocop:disable Rails/DynamicFindBy

    casual_scores = Scores::SoloScores.get
    casual_presenter = Scores::UserScoresPresenter.new(casual_scores)
    casual_participants = casual_presenter.get
    squad_user_uids = @campus.users.pluck(:uid).map(&:to_i)
    @campus_users = casual_participants.select { |p| p[:uid].in? squad_user_uids }
                                       .sort_by { |p| p[:score] * -1 }
    compute_ranks_from_score(@campus_users)

    campus_scores = Scores::CityScores.get
    campus_presenter = Scores::CityScoresPresenter.new(campus_scores)
    campuses = campus_presenter.get
    @campus_stats = campuses.find { |h| h[:id] == @campus.id }
    # TODO: remove when implemented
    @campus_stats[:silver_stars] = @campus_users.sum { |h| h[:silver_stars] }
    @campus_stats[:gold_stars] = @campus_users.sum { |h| h[:gold_stars] }
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
