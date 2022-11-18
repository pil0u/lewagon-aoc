# frozen_string_literal: true

class SquadsController < ApplicationController
  before_action :restrict_after_lock, only: %i[create join leave]

  def show
    @squad = Squad.find(params[:id])

    squad_scores = Scores::SquadScores.get
    squad_presenter = Scores::SquadRanksPresenter.new(squad_scores)
    squads = squad_presenter.ranks
    @squad_stats = squads.find { |h| h[:id] == @squad.id }
    # TODO: remove when implemented
    @squad_stats[:silver_stars] = 0
    @squad_stats[:gold_stars] = 0
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
