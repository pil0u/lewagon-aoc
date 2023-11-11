# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action  :authenticate_user!,  only: %i[code_of_conduct faq participation stats welcome]
  before_action       :render_countdown,    only: %i[code_of_conduct faq participation stats welcome setup], if: :render_countdown?

  def calendar
    user_completions = current_user.completions.group(:day).count
    @advent_days = [
      2,  23, 19, 15, 6,
      14, 10, 1,  22, 18,
      21, 17, 13, 9,  5,
      8,  4,  25, 16, 12,
      20, 11, 7,  3,  24
    ].map do |day|
      {
        parts_solved: user_completions[day] || 0,
        release_time: Aoc.begin_time + (day - 1).days
      }
    end

    @next_puzzle_time = Aoc.next_puzzle_time
    @now = Time.now.getlocal("-05:00")
  end

  def code_of_conduct
    @admins = User.admins.pluck(:username)
  end

  def countdown
    render_countdown
  end

  def faq; end

  def participation
    users_per_city = City.joins(:users).group(:id).count
    @cities = City.all.map do |city|
      n_participants = users_per_city[city.id] || 0

      {
        slug: city.slug,
        name: city.name,
        size: city.size,
        n_participants:,
        participation_ratio: n_participants / city.size.to_f
      }
    end

    @cities.sort_by! { |city| [city[:participation_ratio] * -1, city[:name]] }
  end

  def setup
    @private_leaderboard = ENV.fetch("AOC_ROOMS").split(",").last

    return if cookies[:referral_code].blank?

    current_user.update(referrer: User.find_by_referral_code(cookies[:referral_code]))
    cookies.delete(:referral_code)
  end

  def stats
    @registered_users = User.count
    @confirmed_users = User.confirmed.count
    @participating_users = User.distinct(:id).joins(:completions).count
    @users_with_snippets = User.distinct(:id).joins(:snippets).count
    @total_snippets = Snippet.count

    @gold_stars = Completion.where(challenge: 2).count
    @silver_stars = Completion.where(challenge: 1).count - @gold_stars

    @daily_completers = Completion.group(:day, :challenge).order(:day, :challenge).count # { [12, 1]: 5, [12, 2]: 8, ... }
                                  .group_by { |day_challenge, _| day_challenge.first }   # { 12: [ [[12, 1], 5], [[12, 2], 8] ], ... }
                                  .map do |day, completers|
                                    {
                                      number: day,
                                      gold_completers: completers.dig(1, 1).to_i,
                                      silver_completers: completers.dig(0, 1).to_i - completers.dig(1, 1).to_i
                                    }
                                  end
    @users_per_star = (@daily_completers.map { |h| h[:gold_completers] + h[:silver_completers] }.max.to_f / 50).ceil
  end

  def welcome
    @total_users = User.count

    cookies[:referral_code] = params[:referral_code] if params[:referral_code].present?
  end

  private

  def render_countdown
    render "countdown", layout: false
  end

  def render_countdown?
    Time.now.utc < Aoc.lewagon_launch_time && Rails.env.production? && !ENV["THIS_IS_STAGING"]
  end
end
