# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[admin code_of_conduct faq participation stats welcome]
  skip_before_action :render_countdown, only: %i[admin]

  def admin; end

  def calendar
    @daily_buddy = Buddy.of_the_day(current_user)

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
        release_time: Aoc.release_time(day)
      }
    end

    @now = Aoc.event_timezone.now
    @next_puzzle_time = Aoc.next_puzzle_time
  end

  def code_of_conduct
    @admins = User.admins.pluck(:username)
  end

  def faq; end

  def participation
    users_per_city = City.joins(:users).group(:id).count
    @cities = City.all.map do |city|
      n_participants = users_per_city[city.id] || 0

      {
        slug: city.slug,
        vanity_name: city.vanity_name,
        size: city.size,
        top_contributors: city.top_contributors,
        n_participants:,
        participation_ratio: n_participants / city.size.to_f,
        top_contributors_ratio: n_participants / city.top_contributors.to_f
      }
    end

    @cities.sort_by! { |city| [city[:top_contributors_ratio] * -1, city[:vanity_name]] }
  end

  def patrons
    @users = User.with_aura
    @current_user_referees = current_user.referees
  end

  def setup
    @private_leaderboard = ENV.fetch("AOC_ROOMS").split(",").last
    @sync_status = if current_user.aoc_id.nil? || !current_user.accepted_coc
                     { status: "KO", css_class: "text-wagon-red" }
                   else
                     { status: "Pending", css_class: "text-aoc-atmospheric" }
                   end

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
end
