# frozen_string_literal: true

module Achievements
  class GithubStarMassUnlocker < MassUnlocker
    def call
      uri = URI('https://api.github.com/repos/pil0u/lewagon-aoc/stargazers')
      response = Net::HTTP.get(uri)
      github_usernames = JSON.parse(response).map { |object| object["login"] }
      eligible_users = User.where(github_username: github_usernames)

      unlock_for!(eligible_users)
    end
  end
end
