require 'rails_helper'

RSpec.describe Scores::SquadRanksPresenter do
  let!(:squad_1) { create :squad, id: 1, name: 'The Killers' }
  let!(:squad_2) { create :squad, id: 2, name: 'Grouplove' }
  let!(:squad_3) { create :squad, id: 3, name: 'Longest Johns' }

  let!(:user_1) { create :user, id: 1, squad: squad_1 }
  let!(:user_2) { create :user, id: 2, squad: squad_2 }
  let!(:user_3) { create :user, id: 3, squad: squad_1 }

  let(:input) { [
    { score: 78, squad_id: 1 },
    { score: 100, squad_id: 2 },
    { score: 0, squad_id: 3 },
  ] }

  it "ranks the squads properly" do
    expect(described_class.new(input).ranks).to match([
      hash_including(id: 2, score: 100, rank: 1),
      hash_including(id: 1, score: 78, rank: 2),
      hash_including(id: 3, score: 0, rank: 3),
    ])
  end

  it "completes the squad info" do
    expect(described_class.new(input).ranks).to contain_exactly(
      hash_including(id: 1, name: 'The Killers'),
      hash_including(id: 2, name: 'Grouplove'),
      hash_including(id: 3, name: 'Longest Johns'),
    )
  end

  it "completes the squad stats" do
    expect(described_class.new(input).ranks).to contain_exactly(
      hash_including(id: 1, total_members: 2),
      hash_including(id: 2, total_members: 1),
      hash_including(id: 3, total_members: 0),
    )
  end

  context "in case of equality" do
    let(:input) { [
      { score: 78, squad_id: 1 },
      { score: 100, squad_id: 2 },
      { score: 100, squad_id: 3 },
    ] }

    it "ranks the squads properly" do
      expect(described_class.new(input).ranks).to match([
        hash_including(id: 3, score: 100),
        hash_including(id: 2, score: 100),
        hash_including(id: 1, score: 78),
      ])
    end

    it "uses non-dense ranking" do
      expect(described_class.new(input).ranks).to match([
        hash_including(id: 3, rank: 1),
        hash_including(id: 2, rank: 1),
        hash_including(id: 1, rank: 3),
      ])
    end
  end
end
