# frozen_string_literal: true

class StatsPresenter # rubocop:disable Metrics/ClassLength
  def initialize(user)
    @user = user
  end

  def platform_stats
    {
      registered_users: User.count,
      confirmed_users: User.confirmed.count,
      participating_users: User.distinct(:id).joins(:completions).count,
      users_with_snippets: User.distinct(:id).joins(:snippets).count,
      total_snippets: Snippet.count,
      gold_stars:,
      silver_stars:,
      daily_completers:,
      users_per_star:,
      user_solved_today: @user&.completions&.where(day: Aoc.latest_day)&.count
    }
  end

  def achievements
    {
      influencer: set_influencer_achievement,
      belonging: set_belonging_achievement,
      mobster: set_mobster_achievement,
      fan: set_fan_achievement,
      the_answer: set_the_answer_achievement,
      doomed_sundays: set_doomed_sundays_achievement,
      jeweler: set_jeweler_achievement,
      snake_charmer: set_snake_charmer_achievement,
      picasso: set_picasso_achievement,
      madness: set_madness_achievement,
      jedi_master: set_jedi_master_achievement,
      the_godfather: set_the_godfather_achievement
    }
  end

  private

  def gold_stars
    @gold_stars ||= Completion.where(challenge: 2).count
  end

  def silver_stars
    @silver_stars ||= Completion.where(challenge: 1).count - @gold_stars
  end

  def daily_completers
    @daily_completers ||= Completion.group(:day, :challenge)
                                    .order(:day, :challenge)
                                    .count                                               # { [12, 1]: 5, [12, 2]: 8, ... }
                                    .group_by { |day_challenge, _| day_challenge.first } # { 12: [ [[12, 1], 5], [[12, 2], 8] ], ... }
                                    .map do |day, completers|
                                      {
                                        number: day,
                                        gold_completers: completers.dig(1, 1).to_i,
                                        silver_completers: completers.dig(0, 1).to_i - completers.dig(1, 1).to_i
                                      }
                                    end
  end

  def users_per_star
    max_completers = @daily_completers.map { |dc| dc[:gold_completers] + dc[:silver_completers] }.max
    @users_per_star ||= (max_completers.to_f / 50).ceil
  end

  def set_influencer_achievement
    referrals_count = User.where.not(referrer_id: nil).count
    user_referrals_count = @user&.referees&.count

    state = :locked
    state = :unlocked if referrals_count >= 100
    state = :unlocked_plus if referrals_count >= 100 && user_referrals_count.present?
    title = "Influencer\n\nWe have reached 100 referrals 🤝 Actually #{referrals_count} and counting!"
    title += " - and you have personally invited #{user_referrals_count} of them, thank you for spreading the love <3" if state == :unlocked_plus

    { nature: "influencer", state:, title: }
  end

  def set_belonging_achievement
    user_squad_name = @user&.squad&.name

    state = :locked
    state = :unlocked_plus if user_squad_name.present?
    title = "Belonging\n\nYou are a member of a squad. Time to solve puzzles and bring glory to #{user_squad_name} 💪"

    { nature: "belonging", state:, title: }
  end

  def set_mobster_achievement
    biggest_squad_id = Squad.joins(:users).group(:id).order("COUNT(users.id) DESC, created_at").first&.id
    user_is_in_biggest_squad = @user&.squad_id == biggest_squad_id

    state = :locked
    state = :unlocked_plus if user_is_in_biggest_squad
    title = "Mobster\n\nYou are part of the biggest crime family in town, capisce?"

    { nature: "mobster", state:, title: }
  end

  def set_fan_achievement
    fans = Achievement.fan.joins(:user).pluck("users.id")
    user_is_fan = fans.include?(@user&.id)

    state = :locked
    state = :unlocked if fans.any?
    state = :unlocked_plus if user_is_fan
    title = "Fan\n\n#{ActionController::Base.helpers.pluralize(fans.count, 'participant')} starred the project on GitHub"
    title += " - and you are one of them 🎉" if user_is_fan

    { nature: "fan", state:, title: }
  end

  def set_the_answer_achievement
    state = :locked
    state = :unlocked_plus if Completion.where(challenge: 2).count >= 4242
    title = "The Answer\n\nTogether, we have unlocked the answer to life, the universe, and everything, by collecting 4242 gold stars!"

    { nature: "the_answer", state:, title: }
  end

  def set_doomed_sundays_achievement
    state = :locked
    state = :unlocked_plus if Time.now.utc >= Aoc.end_time.prev_occurring(:sunday)
    title = "Doomed Sundays\n\nYou have survived all Advent Sundays with their extra hard puzzles. We all did. But at what cost?"

    { nature: "doomed_sundays", state:, title: }
  end

  def set_jeweler_achievement
    user_is_jeweler = @user&.snippets&.exists?(language: "ruby")

    state = :locked
    state = :unlocked_plus if user_is_jeweler
    title = "Jeweler\n\nYou have submitted a solution in Ruby, thank you for your contribution"

    { nature: "jeweler", state:, title: }
  end

  def set_snake_charmer_achievement
    user_is_snake_charmer = @user&.snippets&.exists?(language: "python")

    state = :locked
    state = :unlocked_plus if user_is_snake_charmer
    title = "Snake Charmer\n\nYou have submitted a solution in Python, thank you for your contribution"

    { nature: "snake_charmer", state:, title: }
  end

  def set_picasso_achievement
    user_is_picasso = @user&.snippets&.exists?(language: "javascript")

    state = :locked
    state = :unlocked_plus if user_is_picasso
    title = "Picasso\n\nYou have submitted a solution in JavaScript. While the language may look ugly, broken, not following standards, its power make it a real piece of art."

    { nature: "picasso", state:, title: }
  end

  def set_madness_achievement
    madness_holders = Achievement.madness.joins(:user).pluck("users.id")
    user_is_madness_holder = madness_holders.include?(@user&.id)

    state = :locked
    state = :unlocked_plus if user_is_madness_holder
    title = "Madness?\n\nTHIS. IS. CHRISTMAAAAAAAAAAAAAS.\n(you got some points on the ladder of insanity, well done)"

    { nature: "madness", state:, title: }
  end

  def set_jedi_master_achievement
    jedi_masters = Achievement.jedi_master.joins(:user).pluck("users.id", "users.username")
    user_is_jedi_master = jedi_masters.pluck(0).include?(@user&.id)

    state = :locked
    state = :unlocked if jedi_masters.any?
    state = :unlocked_plus if user_is_jedi_master
    title = "Jedi Master\n\nA select few have earned points on the global Advent of Code leaderboard: #{jedi_masters.pluck(1).join(', ')}"
    title += " - and you are on the list! This is the rarest and hardest achievement to unlock, you can be proud." if user_is_jedi_master

    { nature: "jedi_master", state:, title: }
  end

  def set_the_godfather_achievement
    state = :locked
    title = "The Godfather\n\n\"I'm going to make you an offer you can't refuse.\""

    { nature: "the_godfather", state:, title: }
  end
end
