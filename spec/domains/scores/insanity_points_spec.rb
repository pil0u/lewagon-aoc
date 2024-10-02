# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::InsanityPoints do
  let!(:state) { create(:state) }
  let!(:user_1) { create(:user, id: 1, entered_hardcore: true) }
  let!(:user_2) { create(:user, id: 2, entered_hardcore: true) }

  let!(:completions) do
    [
      create_completion(day: 1, challenge: 1, user: user_1, duration: 3.hours + 25.minutes),
      create_completion(day: 1, challenge: 2, user: user_1, duration: 1.day + 12.minutes),
      create_completion(day: 1, challenge: 1, user: user_2, duration: 3.days + 1.minute)
    ]
  end

  def create_completion(day:, challenge:, user:, duration:)
    completion_timestamp = Aoc.begin_time + (day - 1).days + duration
    create(:completion,
           day:,
           challenge:,
           user:,
           completion_unix_time: completion_timestamp.to_i)
  end

  describe "#get" do
    it "computes the points for users for each challenge" do
      expect(described_class.get).to contain_exactly(
        { score: 5, user_id: 1, day: 1, challenge: 1, duration: 3.hours + 25.minutes, completion_id: completions[0].id },
        { score: 5, user_id: 1, day: 1, challenge: 2, duration: 1.day + 12.minutes, completion_id: completions[1].id },
        { score: 4, user_id: 2, day: 1, challenge: 1, duration: 3.days + 1.minute, completion_id: completions[2].id }
      )
    end
  end

  describe "scoring system" do
    let!(:user_3) { create(:user, id: 3, entered_hardcore: true) }
    let!(:user_4) { create(:user, id: 4, entered_hardcore: true) }
    let!(:user_5) { create(:user, id: 5, entered_hardcore: true) }
    let!(:user_6) { create(:user, id: 6, entered_hardcore: true) }
    let!(:user_7) { create(:user, id: 7, entered_hardcore: true) }

    let!(:completions) do
      [
        create_completion(day: 1, challenge: 1, user: user_1, duration: 3.hours + 25.minutes),
        create_completion(day: 1, challenge: 1, user: user_2, duration: 1.day + 2.hours),
        create_completion(day: 1, challenge: 1, user: user_3, duration: 3.hours + 26.minutes),
        create_completion(day: 1, challenge: 1, user: user_4, duration: 3.days + 1.minute),
        create_completion(day: 1, challenge: 1, user: user_5, duration: 4.hours),
        create_completion(day: 1, challenge: 1, user: user_6, duration: 4.hours + 3.minutes),
        create_completion(day: 1, challenge: 1, user: user_7, duration: 4.hours + 5.minutes)
      ]
    end

    it "awards points to the first 5 users who completed the challenge" do
      expect(described_class.get).to include(
        { score: 5, user_id: 1, day: 1, challenge: 1, duration: 3.hours + 25.minutes, completion_id: completions[0].id },
        { score: 4, user_id: 3, day: 1, challenge: 1, duration: 3.hours + 26.minutes, completion_id: completions[2].id },
        { score: 3, user_id: 5, day: 1, challenge: 1, duration: 4.hours, completion_id: completions[4].id },
        { score: 2, user_id: 6, day: 1, challenge: 1, duration: 4.hours + 3.minutes, completion_id: completions[5].id },
        { score: 1, user_id: 7, day: 1, challenge: 1, duration: 4.hours + 5.minutes, completion_id: completions[6].id }
      )
    end

    it "awards 0 points to users who completed the challenge after the 5th position" do
      expect(described_class.get).to include(
        { score: 0, user_id: 2, day: 1, challenge: 1, duration: 1.day + 2.hours, completion_id: completions[1].id },
        { score: 0, user_id: 4, day: 1, challenge: 1, duration: 3.days + 1.minute, completion_id: completions[3].id }
      )
    end

    context "when there are non-insanity users" do
      before { user_5.update!(entered_hardcore: false) }

      it "excludes non-insanity users from the computation" do
        expect(described_class.get).to contain_exactly(
          { score: 5, user_id: 1, day: 1, challenge: 1, duration: 3.hours + 25.minutes, completion_id: completions[0].id },
          { score: 4, user_id: 3, day: 1, challenge: 1, duration: 3.hours + 26.minutes, completion_id: completions[2].id },
          { score: 3, user_id: 6, day: 1, challenge: 1, duration: 4.hours + 3.minutes, completion_id: completions[5].id },
          { score: 2, user_id: 7, day: 1, challenge: 1, duration: 4.hours + 5.minutes, completion_id: completions[6].id },
          { score: 1, user_id: 2, day: 1, challenge: 1, duration: 1.day + 2.hours, completion_id: completions[1].id },
          { score: 0, user_id: 4, day: 1, challenge: 1, duration: 3.days + 1.minute, completion_id: completions[3].id }
        )
      end
    end
  end

  describe "caching behavior" do
    it "creates cache records on the first call" do
      expect { described_class.get }.to change(Cache::InsanityPoint, :count).from(0).to(3)
    end

    context "on subsequent calls" do
      before { described_class.get }

      it "doesn't create new cache records" do
        expect { described_class.get }.not_to change(Cache::InsanityPoint, :count)
      end

      it "doesn't perform any computation" do
        expect_any_instance_of(described_class).not_to receive(:compute)
        described_class.get
      end
    end
  end
end
