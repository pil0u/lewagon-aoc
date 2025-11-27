# frozen_string_literal: true

module Achievements
  class FanMassUnlocker < MassUnlocker
    def call
      uri = URI("https://api.github.com/repos/pil0u/lewagon-aoc/stargazers")
      uri = URI("http://api.github.com/repos/pil0u/lewagon-aoc/stargazers") if Rails.env.development?
      response = Net::HTTP.get_response(uri)

      return unless response.code == "200"

      github_usernames = JSON.parse(response.body).pluck("login")
      eligible_users = User.where(github_username: github_usernames)

      unlock_for!(eligible_users)
    end
  end
end
