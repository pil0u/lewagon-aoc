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

  def faq
    @insanity_points = [
      ["alpha", 1, 1, "1 minute", 5],
      ["bravo", 1, 1, "1 minute 1 second", 4],
      ["charlie", 1, 1, "1 hour", 3],
      ["delta", 1, 1, "2 hours", 2],
      ["echo", 1, 1, "5 days", 1],
      ["foxtrot", 1, 1, "5 days 2 hours", 0],
      ["alpha", 1, 2, "never", 0],
      ["bravo", 1, 2, "6 hours", 4],
      ["charlie", 1, 2, "6 days", 2],
      ["delta", 1, 2, "3 hours", 5],
      ["echo", 1, 2, "5 days 2 hours", 3],
      ["foxtrot", 1, 2, "6 days 1 minute", 1]
    ]
    @insanity_scores = @insanity_points.group_by { |row| row[0] }
                                       .transform_values { |rows| rows.sum { |row| row[4] } }
                                       .sort_by { |_, score| -score }
  end

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
    @patrons = User.with_aura
    @current_user_referees = current_user.referees
  end

  def setup
    @private_leaderboard = ENV.fetch("AOC_ROOMS").split(",").last
    @sync_status = if current_user.aoc_id.nil? || !current_user.accepted_coc
                     { status: "KO", css_class: "text-wagon-red" }
                   else
                     { status: "Pending", css_class: "text-aoc-bronze" }
                   end

    return if cookies[:referral_code].blank?

    current_user.update(referrer: User.find_by_referral_code(cookies[:referral_code]))
    cookies.delete(:referral_code)
  end

  def stats
    # Platform statistics
    @registered_users = User.count
    @confirmed_users = User.confirmed.count
    @participating_users = User.distinct(:id).joins(:completions).count
    @users_with_snippets = User.distinct(:id).joins(:snippets).count
    @total_snippets = Snippet.count

    # Achievements
    set_fan_achievement
    set_the_answer_achievement
    set_doomed_sundays_achievement
    set_influencer_achievement
    set_the_godfather_achievement
    set_belonging_achievement
    set_mobster_achievement
    set_jedi_master_achievement

    # Daily challenge statistics
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

    @current_user_solved_today = current_user.completions.where(day: Aoc.latest_day).count if user_signed_in?
  end

  def welcome
    @total_users = User.count

    cookies[:referral_code] = params[:referral_code] if params[:referral_code].present?
  end

  private

  # Community achievements

  def set_the_answer_achievement
    state = :locked
    state = :unlocked if Completion.where(challenge: 2).count >= 4242
    title = "Together, we have unlocked the answer to life, the universe, and everything, by collecting 4242 gold stars!"

    @the_answer_achievement = { nature: "the_answer", state:, title: }
  end

  def set_doomed_sundays_achievement
    state = :locked
    state = :unlocked if Time.now.utc >= Aoc.end_time.prev_occurring(:sunday)
    title = "You have survived all Advent Sundays with their extra hard puzzles. We all did!"

    @doomed_sundays_achievement = { nature: "doomed_sundays", state:, title: }
  end

  def set_the_godfather_achievement
    state = :locked
    title = "\"I'm going to make you an offer you can't refuse.\""

    @the_godfather_achievement = { nature: "the_godfather", state:, title: }
  end

  # User achievements

  def set_fan_achievement
    fans = Achievement.fan.joins(:user).pluck("users.id")
    current_user_is_fan = fans.pluck(0).include?(current_user&.id)

    state = :locked
    state = :unlocked if fans.any?
    state = :unlocked_plus if current_user_is_fan
    title = "Fan\n\n#{view_context.pluralize(fans.count, 'participant')} starred the project on GitHub"
    title += " - and you are one of them 🎉" if current_user_is_fan

    @fan_achievement = { nature: "fan", state:, title: }
  end

  def set_influencer_achievement
    referrals_count = User.where.not(referrer_id: nil).count
    current_user_referrals_count = current_user&.referees&.count

    state = :locked
    state = :unlocked if referrals_count >= 100
    state = :unlocked_plus if current_user_referrals_count&.> 0
    title = "Influencer\n\nWe have reached 100 referrals 🤝 Actually #{referrals_count} and counting!"
    title += " - and you have personally invited #{current_user_referrals_count} of them, thank you for spreading the love <3" if current_user_referrals_count&.> 0

    @influencer_achievement = { nature: "influencer", state:, title: }
  end

  def set_belonging_achievement
    current_user_squad_name = current_user&.squad&.name

    state = :locked
    state = :unlocked_plus if current_user_squad_name.present?
    title = "Belonging\n\nYou are a member of a squad. Time to solve puzzles and bring glory to #{current_user_squad_name} 💪"

    @belonging_achievement = { nature: "belonging", state:, title: }
  end

  def set_mobster_achievement
    biggest_squad_id = Squad.joins(:users).group(:id).order("COUNT(users.id) DESC").first&.id
    current_user_is_in_biggest_squad = current_user&.squad_id == biggest_squad_id

    state = :locked
    state = :unlocked_plus if current_user_is_in_biggest_squad
    title = "Mobster\n\nYou are part of the biggest crime family in town, capisce?"

    @mobster_achievement = { nature: "mobster", state:, title: }
  end

  def set_jedi_master_achievement
    jedi_masters = Achievement.jedi_master.joins(:user).pluck("users.id", "users.username")
    current_user_is_jedi_master = jedi_masters.pluck(0).include?(current_user&.id)

    state = :locked
    state = :unlocked if jedi_masters.any?
    state = :unlocked_plus if current_user_is_jedi_master
    title = "Jedi Master\n\nA select few have earned points on the global Advent of Code leaderboard: #{jedi_masters.pluck(1).join(', ')}"
    title += " - and you are on the list! This is the rarest and hardest achievement to unlock, you can be proud." if current_user_is_jedi_master

    @jedi_master_achievement = { nature: "jedi_master", state:, title: }
  end
end
