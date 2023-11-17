# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  it "auto-assigns a leaderboard to the user" do
    new_user = create :user, private_leaderboard: nil
    expect(new_user.private_leaderboard).to be_in(Aoc.private_leaderboards)
  end
end
