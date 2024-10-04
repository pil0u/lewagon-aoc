# frozen_string_literal: true

class User < ApplicationRecord
  devise :rememberable, :omniauthable, omniauth_providers: %i[kitt slack_openid]
  encrypts :slack_access_token

  ADMINS = { pilou: "6788", aquaj: "449" }.freeze
  CONTRIBUTORS = { pilou: "6788", aquaj: "449", louis: "19049" }.freeze

  belongs_to :batch, optional: true
  belongs_to :city, optional: true, touch: true
  belongs_to :original_city, class_name: "City", inverse_of: :original_users, optional: true
  belongs_to :squad, optional: true, touch: true
  belongs_to :referrer, class_name: "User", optional: true

  has_many :completions, dependent: :destroy
  has_many :user_day_scores, class_name: "Cache::UserDayScore", dependent: :delete_all
  has_many :solo_points, class_name: "Cache::SoloPoint", dependent: :delete_all
  has_many :solo_scores, class_name: "Cache::SoloScore", dependent: :delete_all
  has_many :insanity_points, class_name: "Cache::InsanityPoint", dependent: :delete_all
  has_many :insanity_scores, class_name: "Cache::InsanityScore", dependent: :delete_all
  has_many :messages, dependent: :nullify
  has_many :snippets, dependent: :nullify
  has_many :achievements, dependent: :destroy
  has_many :referees, class_name: "User", inverse_of: :referrer, dependent: :nullify
  has_many :reactions, dependent: :destroy

  validates :aoc_id, numericality: { in: 1...(2**31), message: "should be between 1 and 2^31" }, allow_nil: true
  validates :aoc_id, uniqueness: { allow_nil: true }
  validates :username, presence: true
  validates :username, length: { maximum: 16 }
  validates :private_leaderboard, presence: true
  validates :favourite_language, inclusion: { in: Snippet::LANGUAGES.keys.map(&:to_s) }, allow_nil: true

  validate :batch_cannot_be_changed,           on: :update, if: :batch_id_changed?
  validate :referrer_must_exist,               on: :update, if: :referrer_id_changed?
  validate :referrer_cannot_be_self,           on: :update

  before_validation :blank_language_to_nil

  scope :admins, -> { where(uid: ADMINS.values) }
  scope :confirmed, -> { where(accepted_coc: true, synced: true).where.not(aoc_id: nil) }
  scope :insanity, -> { where(entered_hardcore: true) } # All users are 'hardcore' since 2024 edition
  scope :contributors, -> { where(uid: CONTRIBUTORS.values) }
  scope :slack_linked, -> { where.not(slack_id: nil) }

  enum :event_awareness, {
    slack_aoc: 0,
    slack_general: 1,
    slack_campus: 2,
    slack_batch: 3,
    newsletter: 4
  }

  before_validation :assign_private_leaderboard, on: :create

  def self.from_kitt(auth)
    oldest_batch = auth.info.schoolings&.min_by { |batch| batch.camp.starts_at }

    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid) do |u|
      u.username = auth.info.github_nickname

      u.batch = Batch.find_or_initialize_by(number: oldest_batch&.camp&.slug.to_i)
      u.city = City.find_or_initialize_by(name: oldest_batch&.city&.name)
    end

    user.github_username = auth.info.github_nickname
    user.original_city_id = City.find_or_initialize_by(name: oldest_batch&.city&.name).id

    user.save
    user
  end

  def self.find_by_referral_code(code)
    return unless code&.match?(/R\d{5}/)

    User.find_by(uid: code.gsub(/R0*/, "").to_i)
  end

  def self.with_aura
    query = <<~SQL.squish
      SELECT
          referrers.uid,
          referrers.username,
          COUNT(referees.id) AS referrals,
          CEIL(100 * (
              LN(COUNT(referees.id) + 1) +                    /* SIGNUPS */
              SUM(LN(COALESCE(completions.total, 0) + 1)) +   /* COMPLETIONS */
              5 * SUM(LN(COALESCE(snippets.total, 0) + 1))    /* CONTRIBUTIONS */
          ))::int AS aura
      FROM users AS referees
      LEFT JOIN users AS referrers
          ON referees.referrer_id = referrers.id
      LEFT JOIN (SELECT user_id, COUNT(id) AS total FROM completions GROUP BY user_id) AS completions
          ON referees.id = completions.user_id
      LEFT JOIN (SELECT user_id, COUNT(id) AS total FROM snippets GROUP BY user_id) AS snippets
          ON referees.id = snippets.user_id
      WHERE referees.referrer_id IS NOT NULL
      GROUP BY 1, 2;
    SQL

    ActiveRecord::Base.connection.exec_query(query, "SQL")
  end

  def admin?
    uid.in?(ADMINS.values)
  end

  def confirmed?
    aoc_id.present? && accepted_coc && synced
  end

  def contributor?
    uid.in?(CONTRIBUTORS.values)
  end

  def slack_linked?
    slack_id.present?
  end

  def slack_link
    "https://lewagon-alumni.slack.com/team/#{slack_id}"
  end

  def solved?(day, challenge)
    Completion.where(user: self, day:, challenge:).any?
  end

  def sync_status
    return "KO" if aoc_id.nil? || !accepted_coc
    return "Pending" unless synced

    "OK"
  end

  def sync_status_css_class
    css_class = {
      "KO" => "text-wagon-red",
      "Pending" => "text-aoc-atmospheric",
      "OK" => "text-aoc-green"
    }

    css_class[sync_status]
  end

  def referral_code
    "R#{uid.to_s.rjust(5, '0')}"
  end

  def referral_link(request)
    "#{request.base_url}/?referral_code=#{referral_code}"
  end

  def referrer_code
    referrer&.referral_code
  end

  private

  def batch_cannot_be_changed
    errors.add(:batch, "can't be changed")
  end

  def blank_language_to_nil
    return if favourite_language.present?

    self.favourite_language = nil
  end

  def referrer_must_exist
    errors.add(:referrer, "must exist") unless User.exists?(referrer_id)
  end

  def referrer_cannot_be_self
    errors.add(:referrer, "can't be you (nice try!)") if referrer == self
  end

  def assign_private_leaderboard
    return if private_leaderboard.present?

    # Count existing users in each private leaderboard
    leaderboards = User.group(:private_leaderboard).count

    # Add the missing private leaderboards
    Aoc.private_leaderboards.each { |leaderboard| leaderboards[leaderboard] ||= 0 }

    # Take the private leaderboard with the least users and assign it to the user
    assigned_leaderboard = leaderboards.min_by { |_, count| count }.first

    update(private_leaderboard: assigned_leaderboard)
  end
end
