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
    # Notice the .to_i[0..30] notation for integer params.
    #
    # Integers are stored on 4 bytes by default on our PostgreSQL database, so any
    # number greater than or equal to 2**31 cannot be stored and throws an error.
    # To mitigate this, we transform any integer we receive to its truncated form to
    # the 31th bit, enforcing any number (even negative) to stay limited to 4 bytes.
    #             (2**31)[0..30] => 0            -1[0..30] => 2**31 - 1

    @params = {
      accepted_terms: form_params[:accepted_terms],
      aoc_id: form_params[:aoc_id],
      batch: Batch.find_or_create_by(number: form_params[:batch_number].to_i[0..30]),
      city: City.find_by(id: form_params[:city_id]),
      username: form_params[:username]
    }.compact
  end

  def form_params
    params.require(:user).permit(:accepted_terms, :aoc_id, :batch_number, :city_id, :username)
  end
end
