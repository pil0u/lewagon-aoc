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
    allow(Scores::SquadPoints).to receive(:get).and_return(squad_points)
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
    end
  end
end
