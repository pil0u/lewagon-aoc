# frozen_string_literal: true

class SquadsController < ApplicationController
  def create
    squad = Squad.create!
    current_user.update(squad_id: squad.id)

    redirect_to settings_path
  end

  def update
    @squad = Squad.find(params[:id])

    if @squad.update(name: squad_params[:name])
      redirect_back(fallback_location: "/settings", notice: "Your squad information was updated")
    else
      redirect_back(fallback_location: "/settings", alert: "Error: #{@squad.errors.full_messages[0]}")
    end
  end

  def join
    @squad = Squad.find_by(secret_id: squad_params[:secret_id])

    if @squad.nil?
      redirect_to settings_path, alert: "This squad does not exist"
      return
    end

    if @squad.users.count >= 4
      redirect_to settings_path, alert: "This squad is full"
      return
    end

    current_user.update(squad_id: @squad.id)
    redirect_to settings_path
  end

  def leave
    squad = Squad.find(current_user.squad_id)

    current_user.update(squad_id: nil)
    squad.destroy! if squad.users.count == 0

    redirect_to settings_path
  end

  private

  def squad_params
    params.require(:squad).permit(:name, :secret_id)
  end
end
