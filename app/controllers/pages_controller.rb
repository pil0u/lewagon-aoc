# frozen_string_literal: true

require 'help'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[home]

  MAGIC_DAYS = [17, 24, 1, 8, 15, 23, 5, 7, 14, 16, 4, 6, 13, 20, 22, 10, 12, 19, 21, 3, 11, 18, 25, 2, 9].freeze

  def home
    @user_count = User.count
  end

  def about; end

  def dashboard
    @status = current_user.status

    @now = Time.now.getlocal("-05:00")
    @day_of_december = @now.day if @now.month == 12
    @last_api_fetch = State.first.last_api_fetch_end
    @next_puzzle_time = @now.month == 12 ? (@now + 1.day).midnight : Time.new(2021, 12, 1, 0, 0, 0, "-05:00")

    sorted_users = Score.group(:user_id).sum(:score_solo).sort_by { |_k, v| -v }
    @my_score = current_user.scores.sum(:score_solo)
    @my_rank = sorted_users.index([current_user.id, @my_score])&.+1 

    @sorted_batches = Score.includes(user: :batch).group(:batch_id).sum(:score_in_batch).except(nil).sort_by { |_k, v| -v }
    @my_batch_score = current_user.batch.scores.sum(:score_in_batch)
    @my_batch_rank = @sorted_batches.index([current_user.batch.id, @my_batch_score])&.+1

    @sorted_cities = Score.includes(user: :city).group(:city_id).sum(:score_in_city).except(nil).sort_by { |_k, v| -v }
    @my_city_score = current_user.city.scores.sum(:score_in_city)
    @my_city_rank = @sorted_cities.index([current_user.city.id, @my_city_score])&.+1

    @my_score_in_batch = current_user.scores.sum(:score_in_batch)
    @my_score_in_city = current_user.scores.sum(:score_in_city)

    @days = MAGIC_DAYS
  end

  def scoreboard; end
end
