# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::SquadPoints do
  let!(:state) { create(:state) }

  let!(:squad_1) { create(:squad, id: 1) }
  let!(:user_1) { create(:user, id: 1, squad: squad_1) }
  let!(:user_2) { create(:user, id: 2, squad: squad_1) }

  let!(:squad_2) { create(:squad, id: 2) }
  let!(:user_3) { create(:user, id: 3, squad: squad_2) }

  let(:insanity_points) do
    [
      { score: 28, user_id: 1, day: 1, challenge: 1 },
      { score: 25, user_id: 1, day: 1, challenge: 2 },

      { score: 25, user_id: 2, day: 1, challenge: 1 },

      { score: 50, user_id: 3, day: 1, challenge: 1 },
      { score: 50, user_id: 3, day: 1, challenge: 2 }
    ]
  end

  before do
    allow(Scores::InsanityPoints).to receive(:get).and_return(insanity_points).once
  end

  it "groups the scores of squad members into the squad score" do
    expect(described_class.get).to contain_exactly(
      { score: 53, squad_id: 1, day: 1, challenge: 1 },
      { score: 25, squad_id: 1, day: 1, challenge: 2 },
      { score: 50, squad_id: 2, day: 1, challenge: 1 },
      { score: 50, squad_id: 2, day: 1, challenge: 2 }
    )
  end

  context "when there are empty squads" do
    let!(:squad_3) { create(:squad, id: 3) }

    it "doesn't output values for squads with no members" do
      expect(described_class.get).not_to include(hash_including(squad_id: 3))
    end
  end

  context "when there are user unaffiliated to any squads" do
    let!(:user_4) { create(:user, id: 4, squad: nil) }

    before do
      insanity_points << { score: 50, user_id: 4, day: 1, challenge: 1 }
    end

    it "does not include their points" do
      expect(described_class.get).not_to include(
        { score: 50, squad_id: nil, day: 1, challenge: 2 }
      )
    end
  end

  describe "caching" do
    it "creates cache records on first call" do
      expect { described_class.get }.to change(Cache::SquadPoint, :count).from(0).to(4)
    end

    context "on second call" do
      before do
        described_class.get
      end

      it "doesn't re-create cache" do
        expect { described_class.get }.not_to change(Cache::SquadPoint, :count)
      end

      it "doesn't do any computation" do
        expect_any_instance_of(described_class).not_to receive(:compute)
        described_class.get
      end

      context "when AOC state has been refetched in the meantime" do
        before do
          create(:state, fetch_api_begin: state.fetch_api_end + 2.seconds)
          allow(Scores::InsanityPoints).to receive(:get).and_return(new_insanity_points).once
        end

        let(:new_insanity_points) do
          [
            { score: 28, user_id: 1, day: 1, challenge: 1 },
            { score: 25, user_id: 1, day: 1, challenge: 2 },

            { score: 25, user_id: 2, day: 1, challenge: 1 },
            { score: 25, user_id: 2, day: 1, challenge: 2 },

            { score: 50, user_id: 3, day: 1, challenge: 1 },
            { score: 50, user_id: 3, day: 1, challenge: 2 }
          ]
        end

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            { score: 53, squad_id: 1, day: 1, challenge: 1 },
            { score: 50, squad_id: 1, day: 1, challenge: 2 },
            { score: 50, squad_id: 2, day: 1, challenge: 1 },
            { score: 50, squad_id: 2, day: 1, challenge: 2 }
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to change(Cache::SquadPoint, :count).from(4).to(8)
        end
      end

      context "when the users makeup of the squad has changed in the meantime" do
        before do
          travel 10.seconds # Specs go too fast, updated_at stays the same otherwise
          user_2.update(squad: create(:squad, id: 3))
          allow(Scores::InsanityPoints).to receive(:get).and_return(insanity_points).once
        end

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            { score: 28, squad_id: 1, day: 1, challenge: 1 },
            { score: 25, squad_id: 1, day: 1, challenge: 2 },
            { score: 50, squad_id: 2, day: 1, challenge: 1 },
            { score: 50, squad_id: 2, day: 1, challenge: 2 },
            { score: 25, squad_id: 3, day: 1, challenge: 1 }
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to change(Cache::SquadPoint, :count).from(4).to(9)
        end
      end
    end
  end
end
