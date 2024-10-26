# frozen_string_literal: true

class User < ApplicationRecord
  include Referrable

  devise :rememberable, :omniauthable, omniauth_providers: %i[kitt slack_openid]
  encrypts :slack_access_token

  flag :roles, %i[admin contributor]
  delegate :admin?, to: :roles
  delegate :contributor?, to: :roles

  enum :event_awareness, {
    slack_aoc: 0,
    slack_general: 1,
    slack_campus: 2,
    slack_batch: 3,
    newsletter: 4
  }

  belongs_to :batch, optional: true
  belongs_to :city, optional: true, touch: true
  belongs_to :original_city, class_name: "City", inverse_of: :original_users, optional: true
  belongs_to :squad, optional: true, touch: true

  has_many :completions, dependent: :destroy
  has_many :user_day_scores, class_name: "Cache::UserDayScore", dependent: :delete_all
  has_many :solo_points, class_name: "Cache::SoloPoint", dependent: :delete_all
  has_many :solo_scores, class_name: "Cache::SoloScore", dependent: :delete_all
  has_many :insanity_points, class_name: "Cache::InsanityPoint", dependent: :delete_all
  has_many :insanity_scores, class_name: "Cache::InsanityScore", dependent: :delete_all
  has_many :messages, dependent: :nullify
  has_many :snippets, dependent: :nullify
  has_many :achievements, dependent: :destroy
  has_many :reactions, dependent: :destroy

  before_validation :assign_private_leaderboard, on: :create
  before_validation :set_years_of_service, on: :create
  before_validation :blank_language_to_nil

  validates :aoc_id, numericality: { in: 1...(2**31), message: "should be between 1 and 2^31" }, allow_nil: true
  validates :aoc_id, uniqueness: { allow_nil: true }
  validates :username, presence: true
  validates :username, length: { maximum: 16 }
  validates :private_leaderboard, presence: true
  validates :favourite_language, inclusion: { in: Snippet::LANGUAGES.keys.map(&:to_s) }, allow_nil: true

  scope :admins, -> { where_roles(:admin) }
  scope :contributors, -> { where_roles(:contributor) }
  scope :confirmed, -> { where(accepted_coc: true, synced: true).where.not(aoc_id: nil) }
  scope :insanity, -> { where(entered_hardcore: true) } # All users are 'hardcore' since 2024 edition
  scope :slack_linked, -> { where.not(slack_id: nil) }

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

  def confirmed?
    aoc_id.present? && accepted_coc && synced
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

  private

  def assign_private_leaderboard
    return if private_leaderboard.present?

    # Count existing users in each private leaderboard
    leaderboards = User.group(:private_leaderboard).count
    # Add the missing private leaderboards
    Aoc.private_leaderboards.each { |leaderboard| leaderboards[leaderboard] ||= 0 }
    # Take the private leaderboard with the least users and assign it to the user
    assigned_leaderboard = leaderboards.min_by { |_, count| count }.first

    self.private_leaderboard = assigned_leaderboard
  end

  def set_years_of_service
    self.years_of_service = CSV.read(Rails.root.join("db/static/participants_all_time.csv"), headers: true)
                               .count { |row| row["kitt_uid"] == uid }
  end

  def blank_language_to_nil
    return if favourite_language.present?

    self.favourite_language = nil
  end
end
