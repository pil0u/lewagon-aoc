# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::SquadScoresPresenter do
  let!(:squad_1) { create :squad, id: 1, name: "The Killers" }
  let!(:squad_2) { create :squad, id: 2, name: "Grouplove" }
  let!(:squad_3) { create :squad, id: 3, name: "Longest Johns" }

  let!(:user_1) { create :user, id: 1, squad: squad_1 }
  let!(:user_2) { create :user, id: 2, squad: squad_2 }
  let!(:user_3) { create :user, id: 3, squad: squad_1 }

  let(:input) do
    [
      { score: 78, squad_id: 1, current_day_score: 20, rank: 2, order: 2 },
      { score: 100, squad_id: 2, current_day_score: 50, rank: 1, order: 1 },
      { score: 0, squad_id: 3, current_day_score: 0, rank: 3, order: 3 }
    ]
  end

  it "ranks the squads properly" do
    expect(described_class.new(input).ranks).to match(
      [
        hash_including(id: 2, score: 100, rank: 1),
        hash_including(id: 1, score: 78, rank: 2),
        hash_including(id: 3, score: 0, rank: 3)
      ]
    )
  end

  it "completes the squad info" do
    expect(described_class.new(input).ranks).to contain_exactly(
      hash_including(id: 1, name: "The Killers"),
      hash_including(id: 2, name: "Grouplove"),
      hash_including(id: 3, name: "Longest Johns")
    )
  end

  it "completes the squad stats" do
    expect(described_class.new(input).ranks).to contain_exactly(
      hash_including(id: 1, total_members: 2, daily_score: 20),
      hash_including(id: 2, total_members: 1, daily_score: 50),
      hash_including(id: 3, total_members: 0, daily_score: 0)
    )
  end

  context "in case of equality" do
    let(:input) do
      [
        { score: 78, squad_id: 1, current_day_score: 20, rank: 3, order: 3 },
        { score: 100, squad_id: 2, current_day_score: 50, rank: 1, order: 2 },
        { score: 100, squad_id: 3, current_day_score: 100, rank: 1, order: 1 }
      ]
    end

    it "ranks the squads properly" do
      expect(described_class.new(input).ranks).to match(
        [
          hash_including(id: 3, score: 100),
          hash_including(id: 2, score: 100),
          hash_including(id: 1, score: 78)
        ]
      )
    end
  end
end
