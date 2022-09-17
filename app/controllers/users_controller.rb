# frozen_string_literal: true

class UsersController < ApplicationController
  def edit
    @squad = Squad.find_or_initialize_by(id: current_user.squad_id)
  end

  def update
    set_updated_params

    if current_user.update(@params)
      redirect_back(fallback_location: "/settings", notice: "Your user information was updated")
    else
      redirect_back(fallback_location: "/settings", alert: "Error: #{current_user.errors.full_messages[0]}")
    end
  end

  private

  def set_updated_params
    @params = {
      accepted_coc: form_params[:accepted_coc],
      aoc_id: form_params[:aoc_id],
      batch_id: Batch.find_or_create_by(number: form_params[:batch_number].to_i).id,
      # find_or_create_by always returns an instance of Batch, even if it failed to create. If creation
      # did fail (from validation), then the id of that instance is nil, which disappears with .compact
      city: City.find_by(id: form_params[:city_id]),
      entered_hardcore: form_params[:entered_hardcore],
      username: form_params[:username]
    }.compact
  end

  def form_params
    params.require(:user).permit(:accepted_coc, :aoc_id, :batch_number, :city_id, :entered_hardcore, :username)
  end
end
