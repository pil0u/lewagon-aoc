# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::InsanityScores do
  let!(:state) { create(:state) }

  let!(:user_1) { create(:user, id: 1, entered_hardcore: true) }
  let!(:user_2) { create(:user, id: 2, entered_hardcore: true) }
  let(:insanity_points) do
    [
      { score: 10, user_id: 1, day: 1, challenge: 1 },
      { score: 10, user_id: 1, day: 1, challenge: 2 },
      { score: 10, user_id: 1, day: 2, challenge: 1 },
      { score: 9, user_id: 2, day: 1, challenge: 1 },
      { score: 9, user_id: 2, day: 2, challenge: 1 }
    ]
  end

  before do
    allow(Aoc).to receive(:latest_day).and_return(2)
    allow(Scores::InsanityPoints).to receive(:get).and_return(insanity_points)
  end

  it "totals the points from each challenge for each user" do
    expect(described_class.get).to contain_exactly(
      hash_including(score: 30, user_id: 1),
      hash_including(score: 18, user_id: 2)
    )
  end

  it "includes the score of the current day" do
    expect(described_class.get).to contain_exactly(
      hash_including(current_day_score: 10, user_id: 1),
      hash_including(current_day_score: 9, user_id: 2)
    )
  end

  context "when a user has no points" do
    let!(:user_3) { create(:user, id: 3, entered_hardcore: true) }

    it "includes them, with 0 points" do
      expect(described_class.get).to include(
        hash_including(score: 0, user_id: 3)
      )
    end
  end

  describe "caching" do
    it "creates cache records on first call" do
      expect { described_class.get }.to change(Cache::InsanityScore, :count).from(0).to(2)
    end

    context "on second call" do
      before do
        described_class.get
      end

      it "doesn't re-create cache" do
        expect { described_class.get }.not_to change(Cache::InsanityScore, :count)
      end

      it "doesn't do any computation" do
        expect_any_instance_of(described_class).not_to receive(:compute)
        described_class.get
      end

      context "when we moved to a new AoC day" do
        before do
          allow(Aoc).to receive(:latest_day).and_return(3)
        end

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            hash_including(user_id: 1, current_day_score: 0),
            hash_including(user_id: 2, current_day_score: 0)
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to change(Cache::InsanityScore, :count).from(2).to(4)
        end
      end
    end
  end
end
