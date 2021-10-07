class UsersController < ApplicationController
  before_action :set_current_user, only: %i[edit update]

  def edit; end

  def update
    batch = Batch.find_or_create_by(number: user_params[:batch_number].presence)
    city = City.find_or_create_by(id: user_params[:city_id])

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
