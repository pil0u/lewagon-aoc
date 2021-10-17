# frozen_string_literal: true

require "aoc"

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[home]

  MAGIC_DAYS = [17, 24, 1, 8, 15, 23, 5, 7, 14, 16, 4, 6, 13, 20, 22, 10, 12, 19, 21, 3, 11, 18, 25, 2, 9].freeze

  def home
    @user_count = User.count
  end

  def about; end

  def dashboard
    @status = current_user.status
    @last_api_fetch = State.first.last_api_fetch_end

    @now = Time.now.getlocal("-05:00")
    @aoc_in_progress = Aoc.in_progress?
    @year = ENV["EVENT_YEAR"] || 2021

    sorted_users = Score.group(:user_id).sum(:score_solo).sort_by { |_k, v| -v }
    @my_score = current_user.scores.sum(:score_solo)
    @my_rank = sorted_users.index([current_user.id, @my_score])&.+1

    @sorted_batches = Score.includes(user: :batch).group(:batch_id).sum(:score_in_batch).except(nil).sort_by { |_k, v| -v }
    if current_user.batch
      @my_batch_score = current_user.batch.scores.sum(:score_in_batch)
      @my_batch_rank = @sorted_batches.index([current_user.batch.id, @my_batch_score])&.+1
      @my_score_in_batch = current_user.scores.sum(:score_in_batch)
    end

    @sorted_cities = Score.includes(user: :city).group(:city_id).sum(:score_in_city).except(nil).sort_by { |_k, v| -v }
    if current_user.city
      @my_city_score = current_user.city.scores.sum(:score_in_city)
      @my_city_rank = @sorted_cities.index([current_user.city.id, @my_city_score])&.+1
      @my_score_in_city = current_user.scores.sum(:score_in_city)
    end

    @next_puzzle_time = Aoc.next_puzzle_time_from(@now)

    @advent_days = MAGIC_DAYS.map { |advent_day| Time.new(2021, 12, advent_day, 0, 0, 0, "-05:00") }
  end

  def scoreboard; end
end
