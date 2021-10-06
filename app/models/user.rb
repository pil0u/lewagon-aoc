class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[kitt]

  belongs_to :batch
  belongs_to :city
  has_many :scores, dependent: :destroy

  def self.from_kitt(auth)
    batch = Batch.find_or_create_by(number: auth.info.last_batch_slug)
    city = City.find_or_create_by(name: auth.info.cities.last)

    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.username = auth.info.github_nickname
      user.batch = batch
      user.city = city
    end
  end

  def status
    return "KO" if aoc_id.nil?

    Score.where(user: self).any? ? "OK" : "pending"
  end
end
