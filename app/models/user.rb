# frozen_string_literal: true

class User < ApplicationRecord
  devise :rememberable, :omniauthable, omniauth_providers: %i[kitt]

  ADMINS = { pilou: "6788", aquaj: "449" }.freeze
  CONTRIBUTORS = { pilou: "6788", aquaj: "449", louis: "19049", aurelie: "9168" }.freeze

  belongs_to :batch, optional: true
  belongs_to :squad, optional: true, touch: true
  belongs_to :referrer, class_name: "User", optional: true

  delegate :city, :city_id, to: :batch, allow_nil: true

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

  validates :aoc_id, numericality: { in: 1...(2**31), message: "should be between 1 and 2^31" }, allow_nil: true
  validates :aoc_id, uniqueness: { allow_nil: true }
  validates :username, presence: true

  validate :not_referring_self

  scope :admins, -> { where(uid: ADMINS.values) }
  scope :confirmed, -> { where(accepted_coc: true, synced: true).where.not(aoc_id: nil) }
  scope :insanity, -> { where(entered_hardcore: true) }
  scope :contributors, -> { where(uid: CONTRIBUTORS.values) }

  after_create :assign_private_leaderboard

  def self.from_kitt(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_create do |u|
      u.username = auth.info.github_nickname
      u.github_username = auth.info.github_nickname
      u.batch_id = Batch.find_or_create_by(number: auth.info.last_batch_slug.to_i).id
    end

    user.update(github_username: auth.info.github_nickname)
    user
  end

  def self.find_by_referral_code(code)
    uid = code&.gsub(/R0*/, "")&.to_i
    return if uid.nil?

    User.find_by(uid:)
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

  def referrer_code
    referrer&.referral_code
  end

  private

  def not_referring_self
    errors.add(:referrer, "must not be you") if referrer == self
  end

  def assign_private_leaderboard
    # Count existing users in each private leaderboard
    leaderboards = User.group(:private_leaderboard).count

    # Add the missing private leaderboards
    Aoc.private_leaderboards.each { |leaderboard| leaderboards[leaderboard] ||= 0 }

    # Take the private leaderboard with the least users and assign it to the user
    assigned_leaderboard = leaderboards.min_by { |_, count| count }.first

    update(private_leaderboard: assigned_leaderboard)
  end
end
