# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::InsanityPoints do
  let!(:state) { create(:state) }
  let!(:user_1) { create(:user, id: 1, entered_hardcore: true) }
  let!(:user_2) { create(:user, id: 2, entered_hardcore: true) }

  let!(:completions) do
    [
      create_completion(1, 1, user_1, 3.hours + 25.minutes),
      create_completion(1, 2, user_1, 1.day + 12.minutes),
      create_completion(1, 1, user_2, 3.days + 1.minute)
    ]
  end

  def create_completion(day, challenge, user, duration)
    completion_timestamp = Aoc.begin_time + (day - 1).days + duration
    create(:completion,
           day:,
           challenge:,
           user:,
           completion_unix_time: completion_timestamp.to_i)
  end

  it "computes the points for users for each challenge" do
    expect(described_class.get).to contain_exactly(
      { score: 5, user_id: 1, day: 1, challenge: 1, completion_id: completions[0].id },
      { score: 5, user_id: 1, day: 1, challenge: 2, completion_id: completions[1].id },
      { score: 4, user_id: 2, day: 1, challenge: 1, completion_id: completions[2].id }
    )
  end

  describe "scoring" do
    let!(:user_3) { create(:user, id: 3, entered_hardcore: true) }
    let!(:user_4) { create(:user, id: 4, entered_hardcore: true) }
    let!(:user_5) { create(:user, id: 5, entered_hardcore: true) }
    let!(:user_6) { create(:user, id: 6, entered_hardcore: true) }
    let!(:user_7) { create(:user, id: 7, entered_hardcore: true) }

    let!(:completions) do
      [
        create_completion(1, 1, user_1, 3.hours + 25.minutes),
        create_completion(1, 1, user_2, 1.day + 2.hours),
        create_completion(1, 1, user_3, 3.hours + 26.minutes),
        create_completion(1, 1, user_4, 3.days + 1.minute),
        create_completion(1, 1, user_5, 4.hours),
        create_completion(1, 1, user_6, 4.hours + 3.minutes),
        create_completion(1, 1, user_7, 4.hours + 5.minutes)
      ]
    end

    it "grants the first 5 users who completed the challenge respectively 5, 4, 3, 2 and 1 points" do
      expect(described_class.get).to include(
        { score: 5, user_id: 1, day: 1, challenge: 1, completion_id: completions[0].id },
        { score: 4, user_id: 3, day: 1, challenge: 1, completion_id: completions[2].id },
        { score: 3, user_id: 5, day: 1, challenge: 1, completion_id: completions[4].id },
        { score: 2, user_id: 6, day: 1, challenge: 1, completion_id: completions[5].id },
        { score: 1, user_id: 7, day: 1, challenge: 1, completion_id: completions[6].id }
      )
    end

    it "grants 0 point to any other user who completed the challenge after the 5th" do
      expect(described_class.get).to include(
        { score: 0, user_id: 2, day: 1, challenge: 1, completion_id: completions[1].id },
        { score: 0, user_id: 4, day: 1, challenge: 1, completion_id: completions[3].id }
      )
    end

    context "when there are non-insanity users" do
      before do
        user_5.update!(entered_hardcore: false)
      end

      it "does not include them in the computation" do
        expect(described_class.get).to contain_exactly(
          { score: 5, user_id: 1, day: 1, challenge: 1, completion_id: completions[0].id },
          { score: 4, user_id: 3, day: 1, challenge: 1, completion_id: completions[2].id },
          { score: 3, user_id: 6, day: 1, challenge: 1, completion_id: completions[5].id },
          { score: 2, user_id: 7, day: 1, challenge: 1, completion_id: completions[6].id },
          { score: 1, user_id: 2, day: 1, challenge: 1, completion_id: completions[1].id },
          { score: 0, user_id: 4, day: 1, challenge: 1, completion_id: completions[3].id }
        )
      end
    end
  end

  describe "caching" do
    it "creates cache records on first call" do
      expect { described_class.get }.to change(Cache::InsanityPoint, :count).from(0).to(3)
    end

    context "on second call" do
      before do
        described_class.get
      end

      it "doesn't re-create cache" do
        expect { described_class.get }.not_to change(Cache::InsanityPoint, :count)
      end

      it "doesn't do any computation" do
        expect_any_instance_of(described_class).not_to receive(:compute)
        described_class.get
      end
    end
  end
end
