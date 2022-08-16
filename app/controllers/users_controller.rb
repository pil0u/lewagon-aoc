# frozen_string_literal: true

class UsersController < ApplicationController
  def edit
    set_current_user
  end

  def update
    set_current_user
    set_updated_params

    if @user.update(@params)
      redirect_back(fallback_location: "/", notice: "Your information was updated")
    else
      redirect_back(fallback_location: "/", alert: "Error: #{@user.errors.full_messages[0]}")
    end
  end

  private

  def set_current_user
    @user = current_user
  end

  def set_updated_params
    @params = {
      accepted_terms: form_params[:accepted_terms],
      aoc_id: form_params[:aoc_id],
      batch_id: Batch.find_or_create_by(number: form_params[:batch_number].to_i).id,
      # find_or_create_by always returns an instance of Batch, even if it failed to create. If creation
      # did fail (from validation), then the id of that instance is nil, which disappears with .compact
      city: City.find_by(id: form_params[:city_id]),
      username: form_params[:username]
    }.compact
  end

  def form_params
    params.require(:user).permit(:accepted_terms, :aoc_id, :batch_number, :city_id, :username)
  end
end
