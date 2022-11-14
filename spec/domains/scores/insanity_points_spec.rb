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
      create_completion(1, 1, user_2, 3.days + 1.minute),
    ]
  end

  def create_completion(day, challenge, user, duration)
    completion_timestamp = DateTime.new(2022, 12, 0 + day, 6, 0, 0) + duration
    create(:completion,
      day:,
      challenge:,
      user:,
      completion_unix_time: completion_timestamp.to_i,
    )
  end

  it "computes the points for users for each challenge" do
    expect(described_class.get).to contain_exactly(
      { score: 2, user_id: 1, day: 1, challenge: 1 },
      { score: 2, user_id: 1, day: 1, challenge: 2 },
      { score: 1, user_id: 2, day: 1, challenge: 1 },
    )
  end

  describe "scoring" do
    let!(:user_3) { create(:user, id: 3, entered_hardcore: true) }
    let!(:user_4) { create(:user, id: 4, entered_hardcore: true) }
    let!(:user_5) { create(:user, id: 5, entered_hardcore: true) }

    let!(:completions) do
      [
        create_completion(1, 1, user_1, 3.hours + 25.minutes),
        create_completion(1, 1, user_3, 3.hours + 26.minutes),
        create_completion(1, 1, user_5, 4.hours),
        create_completion(1, 1, user_2, 1.day + 2.hours),
        create_completion(1, 1, user_4, 3.days + 1.minute),
      ]
    end

    it "gives the first user to complete the challenge as many points as there are players" do
      expect(described_class.get).to include(
        { score: 5, user_id: 1, day: 1, challenge: 1 },
      )
    end

    it "gives each player one less point per player ahead of them" do
      expect(described_class.get).to include(
        { score: 4, user_id: 3, day: 1, challenge: 1 },
        { score: 3, user_id: 5, day: 1, challenge: 1 },
        { score: 2, user_id: 2, day: 1, challenge: 1 },
        { score: 1, user_id: 4, day: 1, challenge: 1 },
      )
    end

    context "when there are non-insanity users" do
      before do
        user_5.update!(entered_hardcore: false)
      end

      it "does not include them in the computation" do
        expect(described_class.get).to contain_exactly(
          { score: 4, user_id: 1, day: 1, challenge: 1 },
          { score: 3, user_id: 3, day: 1, challenge: 1 },
          { score: 2, user_id: 2, day: 1, challenge: 1 },
          { score: 1, user_id: 4, day: 1, challenge: 1 },
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
