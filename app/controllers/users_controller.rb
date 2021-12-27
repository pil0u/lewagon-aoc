# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_current_user, only: %i[edit update]

  def edit; end

  def update
    batch_number = user_params[:batch_number]&.gsub(/[^\d]/, "")
    if batch_number.to_i > (2**31) - 1 # The batch number is stored as a 4-bytes integer in the database
      redirect_to settings_path, notice: "Please enter a valid batch number"
      return
    end
    batch = Batch.find_or_create_by(number: batch_number) if batch_number.present?

    city = City.find(user_params[:city_id]) if user_params[:city_id].present?

    @user.attributes = {
      username: user_params[:username],
      aoc_id: user_params[:aoc_id],
      batch: batch,
      city: city
    }

    if @user.save
      redirect_to settings_path, notice: "Your information was updated"
    else
      render :edit
    end
  end

  private

  def set_current_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:username, :aoc_id, :batch_number, :city_id)
  end
end
