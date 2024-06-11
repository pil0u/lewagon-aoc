# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  it "auto-assigns a leaderboard to the user" do
    new_user = create :user, private_leaderboard: nil
    expect(new_user.private_leaderboard).to be_in(Aoc.private_leaderboards)
  end

  describe "::with_aura" do
    it "returns a ActiveRecord::Result" do
      expect(User.with_aura.class).to eq ActiveRecord::Result
    end

    it "returns a list of users that have at least 1 referral" do
      expect(User.with_aura.pluck("referrals")).to all be_positive
    end

    it "returns a list of users with attributes uid, username, referrals and aura" do
      expect(User.with_aura.columns).to contain_exactly("uid", "username", "referrals", "aura")
    end

    it "computes the aura correctly" do
      referrer = create(:user, uid: "1")

      referee_one = create(:user, username: "Aquaj", uid: "2", referrer:)
      referee_two = create(:user, username: "wJoenn", uid: "3", referrer:)
      referee_three = create(:user, username: "Aurrou", uid: "4", referrer:)
      create(:user, username: "Nikos", uid: "5", referrer: referee_one)

      build_list(:completion, 3, user: referee_one) do |completion, i|
        completion.day = i + 1
        completion.save!
      end
      build_list(:completion, 5, user: referee_two) do |completion, i|
        completion.day = i + 1
        completion.save!
      end
      build_list(:completion, 8, user: referee_three) do |completion, i|
        completion.day = i + 1
        completion.save!
      end

      create(:snippet, user: referee_one, language: "ruby", code: "some code")
      create(:snippet, user: referee_one, language: "python", code: "some code")
      create(:snippet, user: referee_two, language: "ruby", code: "some code")
      create(:snippet, user: referee_two, language: "python", code: "some code")
      create(:snippet, user: referee_two, language: "javascript", code: "some code")

      expect(User.with_aura).to contain_exactly(
        hash_including("uid" => "1", "username" => "pil0u", "referrals" => 3, "aura" => 1919),  # (100 * (ln(3+1) + (ln(3+1) + ln(5+1) + ln(8+1)) + 5 * (ln(2+1) + ln(3+1)))).ceil
        hash_including("uid" => "2", "username" => "Aquaj", "referrals" => 1, "aura" => 70)     # (100 * (ln(1+1) + 0                             + 5 * 0)).ceil
      )
    end
  end
end
