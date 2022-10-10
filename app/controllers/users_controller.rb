# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :restrict_after_lock, only: %i[update]

  def show
    @user = User.find_by(uid: params[:uid])
  end

  def edit
    @squad = Squad.find_or_initialize_by(id: current_user.squad_id)
  end

  def update
    set_updated_params

    if current_user.update(@params)
      redirect_back fallback_location: "/", notice: "Your user information was updated"
    else
      redirect_back fallback_location: "/", alert: current_user.errors.full_messages[0].to_s
    end
  end

  private

  def restrict_after_lock
    if Time.now.utc > Aoc.lock_time && (form_params[:entered_hardcore] == "1") != current_user.entered_hardcore
      redirect_back(
        fallback_location: "/",
        alert: "You cannot join or leave the Ladder of Insanity since #{Aoc.lock_time.to_fs(:long_ordinal)} (see FAQ)"
      )
    end
  end

  def set_updated_params
    @params = {
      accepted_coc: form_params[:accepted_coc],
      aoc_id: form_params[:aoc_id],
      batch_id: Batch.find_or_create_by(number: form_params[:batch_number].to_i).id,
      # find_or_create_by always returns an instance of Batch, even if it failed to create. If creation did fail (from
      # validation), then the id of that instance is nil, which disappears with .compact below
      city: City.find_by(id: form_params[:city_id]),
      entered_hardcore: form_params[:entered_hardcore],
      username: form_params[:username]
    }.compact
  end

  def form_params
    params.require(:user).permit(:accepted_coc, :aoc_id, :batch_number, :city_id, :entered_hardcore, :username)
  end
end
