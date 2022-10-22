require 'rails_helper'

RSpec.describe Scores::SquadScores do
  let!(:state) { create(:state) }

  let!(:squad_1) { create(:squad, id: 1) }
  let!(:squad_2) { create(:squad, id: 2) }
  let!(:squad_3) { create(:squad, id: 3) }

  let(:squad_points) { [
    { score: 53, squad_id: 1, day: 1, challenge: 1 },
    { score: 25, squad_id: 1, day: 1, challenge: 2 },
    { score: 50, squad_id: 2, day: 1, challenge: 1 },
    { score: 50, squad_id: 2, day: 1, challenge: 2 },
  ] }

  before do
    allow(Scores::SquadPoints).to receive(:get).and_return(squad_points).once
  end

  it "groups the scores of squad members into the squad score" do
    expect(described_class.get).to contain_exactly(
      { score: 78, squad_id: 1 },
      { score: 100, squad_id: 2 },
    )
  end

  describe "caching" do
    it "creates cache records on first call" do
      expect { described_class.get }.to change { Cache::SquadScore.count }.from(0).to(2)
    end

    context "on second call" do
      before do
        described_class.get
      end

      it "doesn't re-create cache" do
        expect { described_class.get }.not_to change { Cache::SquadScore.count }
      end

      it "doesn't do any computation" do
        expect_any_instance_of(described_class).not_to receive(:compute)
        described_class.get
      end

      context "when AOC state has been refetched in the meantime" do
        before do
          create(:state, fetch_api_begin: state.fetch_api_end + 2.seconds)
          allow(Scores::SquadPoints).to receive(:get).and_return(new_squad_points).once
        end

        let(:new_squad_points) { [
          { score: 53, squad_id: 1, day: 1, challenge: 1 },
          { score: 50, squad_id: 1, day: 1, challenge: 2 },
          { score: 50, squad_id: 2, day: 1, challenge: 1 },
          { score: 50, squad_id: 2, day: 1, challenge: 2 },
        ] }

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            { score: 103, squad_id: 1 },
            { score: 100, squad_id: 2 },
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to change { Cache::SquadScore.count }.from(2).to(4)
        end
      end

      context "when the users makeup of the squad has changed in the meantime" do
        before do
          travel 10.seconds # Specs go too fast, updated_at stays the same otherwise
          create(:user, squad: squad_3)
          allow(Scores::SquadPoints).to receive(:get).and_return(new_squad_points).once
        end

        let(:new_squad_points) { [
          { score: 53, squad_id: 1, day: 1, challenge: 1 },
          { score: 25, squad_id: 1, day: 1, challenge: 2 },
          { score: 50, squad_id: 2, day: 1, challenge: 1 },
          { score: 50, squad_id: 2, day: 1, challenge: 2 },
          { score: 50, squad_id: 3, day: 1, challenge: 1 },
        ] }

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            { score: 78, squad_id: 1 },
            { score: 100, squad_id: 2 },
            { score: 50, squad_id: 3 },
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to change { Cache::SquadScore.count }.from(2).to(5)
        end
      end
    end
  end
end
