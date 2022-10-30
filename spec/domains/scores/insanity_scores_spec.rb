# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::InsanityScores do
  let!(:state) { create(:state) }

  let!(:user_1) { create(:user, id: 1) }
  let!(:user_2) { create(:user, id: 2) }
  let(:insanity_points) do
    [
      { score: 10, user_id: 1, day: 1, challenge: 1 },
      { score: 10, user_id: 1, day: 1, challenge: 2 },
      { score: 9, user_id: 2, day: 1, challenge: 1 }
    ]
  end

  before do
    allow(Scores::InsanityPoints).to receive(:get).and_return(insanity_points)
  end

  it "totals the points from each challenge for each user" do
    expect(described_class.get).to contain_exactly(
      { score: 20, user_id: 1 },
      { score: 9, user_id: 2 }
    )
  end

  context "when a user has no points" do
    let!(:user_3) { create(:user, id: 3) }

    it "still includes it in the scores with 0 points" do
      expect(described_class.get).to include(
        { score: 0, user_id: 3 }
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
    end
  end
end