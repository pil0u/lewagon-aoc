class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: %i[kitt]

  belongs_to :batch
  belongs_to :city
  has_many :scores

  def self.from_kitt(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.username = auth.info.github_nickname
    end
  end
end
