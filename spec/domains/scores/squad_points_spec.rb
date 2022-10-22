require 'rails_helper'

RSpec.describe Scores::SquadPoints do
  let!(:state) { create(:state) }

  let!(:squad_1) { create(:squad, id: 1) }
  let!(:user_1) { create(:user, id: 1, squad: squad_1) }
  let!(:user_2) { create(:user, id: 2, squad: squad_1) }

  let!(:squad_2) { create(:squad, id: 2) }
  let!(:user_3) { create(:user, id: 3, squad: squad_2) }

  let!(:squad_3) { create(:squad, id: 3) }

  let(:solo_points) { [
    { score: 28, user_id: 1, day: 1, challenge: 1 },
    { score: 25, user_id: 1, day: 1, challenge: 2 },

    { score: 25, user_id: 2, day: 1, challenge: 1 },

    { score: 50, user_id: 3, day: 1, challenge: 1 },
    { score: 50, user_id: 3, day: 1, challenge: 2 },
  ] }

  before do
    allow(Scores::SoloPoints).to receive(:get).and_return(solo_points)
  end

  it "groups the scores of squad members into the squad score" do
    expect(described_class.get).to contain_exactly(
      { score: 53, squad_id: 1, day: 1, challenge: 1 },
      { score: 25, squad_id: 1, day: 1, challenge: 2 },
      { score: 50, squad_id: 2, day: 1, challenge: 1 },
      { score: 50, squad_id: 2, day: 1, challenge: 2 },
    )
  end

  it "doesn't output values for squads with no members" do
    expect(described_class.get).not_to include(hash_including(squad_id: 3))
  end

  context "when there are user unaffiliated to any squads" do
    let!(:user_4) { create(:user, id: 4, squad: nil) }
    before do
      solo_points << { score: 50, user_id: 4, day: 1, challenge: 1 }
    end

    it "does not include their points" do
      expect(described_class.get).not_to include(
        { score: 50, squad_id: nil, day: 1, challenge: 2 },
      )
    end
  end

  describe "caching" do
    it "creates cache records on first call" do
      expect { described_class.get }.to change { Cache::SquadPoint.count }.from(0).to(4)
    end

    context "on second call" do
      before do
        described_class.get
      end

      it "doesn't re-create cache" do
        expect { described_class.get }.not_to change { Cache::SquadPoint.count }
      end

      it "doesn't do any computation" do
        expect_any_instance_of(described_class).not_to receive(:compute)
        described_class.get
      end
    end
  end
end
