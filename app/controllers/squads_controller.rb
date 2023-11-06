# frozen_string_literal: true

class SquadsController < ApplicationController
  before_action :restrict_after_lock, only: %i[create join leave]

  def show
    @squad = Squad.find(params[:id])

    casual_scores = Scores::SoloScores.get
    casual_presenter = Scores::UserScoresPresenter.new(casual_scores)
    casual_participants = casual_presenter.get
    squad_user_uids = @squad.users.pluck(:uid).map(&:to_i)
    @squad_users = casual_participants.select { |p| p[:uid].in? squad_user_uids }
                                      .sort_by { |p| p[:score] * -1 }
    compute_ranks_from_score(@squad_users)

    squad_scores = Scores::SquadScores.get
    squad_presenter = Scores::SquadScoresPresenter.new(squad_scores)
    squads = squad_presenter.get
    @squad_stats = squads.find { |h| h[:id] == @squad.id }
    # TODO: remove when implemented
    @squad_stats[:silver_stars] = @squad_users.sum { |h| h[:silver_stars] }
    @squad_stats[:gold_stars] = @squad_users.sum { |h| h[:gold_stars] }
  end

  def create
    squad = Squad.create!
    current_user.update(squad_id: squad.id)

    redirect_to settings_path, notice: "Squad successfully created!"
  end

  def update
    @squad = Squad.find(params[:id])

    if @squad.update(name: squad_params[:name])
      redirect_to settings_path, notice: "Your squad information was updated"
    else
      redirect_to settings_path, alert: @squad.errors.full_messages[0].to_s
    end
  end

  def join
    @squad = Squad.find_by(pin: squad_params[:pin])

    if @squad.nil?
      redirect_to settings_path, alert: "This squad does not exist"
      return
    end

    if @squad.users.count >= 4
      redirect_to settings_path, alert: "This squad is full"
      return
    end

    current_user.update(squad_id: @squad.id)
    redirect_to settings_path, notice: "Squad successfully joined!"
  end

  def leave
    squad = Squad.find(current_user.squad_id)

    current_user.update(squad_id: nil)
    squad.destroy! if squad.users.count == 0

    redirect_to settings_path, notice: "Squad successfully left."
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

  def restrict_after_lock
    return unless Time.now.utc > Aoc.lock_time

    redirect_to(
      settings_path,
      alert: "You cannot #{action_name} Squads since #{Aoc.lock_time.to_fs(:long_ordinal)} (see FAQ)"
    )
  end

  def squad_params
    params.require(:squad).permit(:name, :pin)
  end
end
