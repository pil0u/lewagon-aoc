# frozen_string_literal: true

class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[kitt]

  CONTRIBUTORS = %w[6788 449 5083 6888].freeze

  belongs_to :batch, optional: true
  belongs_to :city, optional: true
  has_many :completions, dependent: :destroy
  has_one :score # rubocop:disable Rails/HasManyOrHasOneDependent -- this is an SQL view
  has_one :rank # rubocop:disable Rails/HasManyOrHasOneDependent -- this is an SQL view
  has_many :city_contributions, through: :completions
  has_many :batch_contributions, through: :completions

  validates :aoc_id, numericality: { in: 1...(2**31), message: "should be between 1 and 2^31" }, allow_nil: true

  scope :synced, -> { where(synced: true) }
  scope :contributors, -> { where(uid: CONTRIBUTORS) }

  after_save do
    Help.refresh_views! if saved_changes.include? "batch_id"
  end

  def self.from_kitt(auth)
    user = where(provider: auth.provider, uid: auth.uid).first_or_create do |u|
      u.username = auth.info.github_nickname
      u.github_username = auth.info.github_nickname
      u.batch_id = Batch.find_or_create_by(number: auth.info.last_batch_slug.to_i).id
    end

    user.update(github_username: auth.info.github_nickname)
    user
  end

  def self.update_sync_status_from(members)
    member_ids = members.keys.map(&:to_i)

    find_each do |user|
      new_synced = member_ids.include?(user.aoc_id)

      if user.synced != new_synced
        user.update(synced: new_synced)
        Rails.logger.info "#{user.id}-#{user.username} is now #{new_synced ? '' : 'un'}synced."
      end
    end
  end

  def friendly_status
    return "KO" if aoc_id.nil? || !accepted_coc
    return "Pending" unless synced

    "OK"
  end

  def blazer?
    uid.in?({ pilou: "6788", aquaj: "449" }.values)
  end

  def confirmed?
    aoc_id.present? && accepted_coc && synced
  end
end
