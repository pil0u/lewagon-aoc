# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_current_user, only: %i[edit update]

  def edit; end

  def update
    batch = Batch.find_or_create_by(number: user_params[:batch_number]) if user_params[:batch_number].present?
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

  def city
    @city_mates = current_user.city.users
      .left_joins(:batch).joins(:score, :rank).preload(:score, :rank, :batch)
      .order('ranks.in_city')
  end

  def batch
    @batch_mates = current_user.batch.users
      .left_joins(:city).joins(:score, :rank).preload(:score, :rank, :city)
      .order('ranks.in_batch')
  end

  private

  def set_current_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:username, :aoc_id, :batch_number, :city_id)
  end
end
