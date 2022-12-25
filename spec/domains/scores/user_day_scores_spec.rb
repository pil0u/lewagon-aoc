# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::UserDayScores do
  let!(:state) { create(:state) }

  let!(:user_1) { create(:user, id: 1) }
  let!(:user_2) { create(:user, id: 2) }
  let(:solo_points) do
    [
      { score: 50, user_id: 1, day: 1, challenge: 1, completion_id: 1 },
      { score: 49, user_id: 1, day: 1, challenge: 2, completion_id: 2 },
      { score: 50, user_id: 1, day: 2, challenge: 1, completion_id: 4 },
      { score: 25, user_id: 2, day: 1, challenge: 1, completion_id: 3 },
      { score: 40, user_id: 2, day: 2, challenge: 1, completion_id: 5 }
    ]
  end

  before do
    allow(Aoc).to receive(:latest_day).and_return(2)
    allow(Scores::SoloPoints).to receive(:get).and_return(solo_points)
  end

  it "totals the points from each challenge for each user grouped by day" do
    expect(described_class.get).to contain_exactly(
      hash_including(score: 99, user_id: 1, day: 1),
      hash_including(score: 50, user_id: 1, day: 2),
      hash_including(score: 25, user_id: 2, day: 1),
      hash_including(score: 40, user_id: 2, day: 2)
    )
  end

  it "provides the completion_ids for the parts if available" do
    expect(described_class.get).to contain_exactly(
      hash_including(user_id: 1, day: 1, part_1_completion_id: 1, part_2_completion_id: 2),
      hash_including(user_id: 1, day: 2, part_1_completion_id: 4, part_2_completion_id: nil),
      hash_including(user_id: 2, day: 1, part_1_completion_id: 3, part_2_completion_id: nil),
      hash_including(user_id: 2, day: 2, part_1_completion_id: 5, part_2_completion_id: nil)
    )

  end

  describe "caching" do
    it "creates cache records on first call" do
      expect { described_class.get }.to change(Cache::UserDayScore, :count).from(0).to(4)
    end

    context "on second call" do
      before do
        described_class.get
      end

      it "doesn't re-create cache" do
        expect { described_class.get }.not_to change(Cache::SoloScore, :count)
      end

      it "doesn't do any computation" do
        expect_any_instance_of(described_class).not_to receive(:compute)
        described_class.get
      end
    end
  end
end
