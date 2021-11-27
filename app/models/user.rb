# frozen_string_literal: true

class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[kitt]

  belongs_to :batch, optional: true
  belongs_to :city, optional: true
  has_many :completions, dependent: :destroy
  has_one :score
  has_one :rank

  scope :synced, -> { where(synced: true) }

  def self.from_kitt(auth)
    batch_from_oauth = auth.info.last_batch_slug
    batch = Batch.find_or_create_by(number: batch_from_oauth) if batch_from_oauth.present?

    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.username = auth.info.github_nickname
      user.batch = batch
    end
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

  def status
    return "KO" if aoc_id.nil?

    synced ? "OK" : "pending"
  end
end
