# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::CityRanksPresenter do
  let!(:city_1) { create :city, id: 1, name: "Bordeaux", size: 200 }
  let!(:city_2) { create :city, id: 2, name: "Rio de Janeiro", size: 100 }
  let!(:city_3) { create :city, id: 3, name: "Paris", size: 500 }

  let!(:user_1) { create :user, id: 1, city: city_1 }
  let!(:user_2) { create :user, id: 2, city: city_2 }
  let!(:user_3) { create :user, id: 3, city: city_1 }

  let(:input) do
    [
      { score: 125, city_id: 1 },
      { score: 126, city_id: 2 },
      { score: 0,   city_id: 3 }
    ]
  end

  it "ranks the cities properly" do
    expect(described_class.new(input).ranks).to match(
      [
        hash_including(id: 2, score: 126, rank: 1),
        hash_including(id: 1, score: 125, rank: 2),
        hash_including(id: 3, score: 0, rank: 3)
      ]
    )
  end

  it "completes the city info" do
    expect(described_class.new(input).ranks).to contain_exactly(
      hash_including(id: 1, name: "Bordeaux", slug: "bordeaux"),
      hash_including(id: 2, name: "Rio de Janeiro", slug: "rio-de-janeiro"),
      hash_including(id: 3, name: "Paris", slug: "paris")
    )
  end

  it "completes the city stats" do
    expect(described_class.new(input).ranks).to contain_exactly(
      hash_including(id: 1, total_members: 2, top_contributors: 10),
      hash_including(id: 2, total_members: 1, top_contributors: 10),
      hash_including(id: 3, total_members: 0, top_contributors: 15)
    )
  end

  context "in case of equality" do
    let(:input) do
      [
        { score: 126, city_id: 1 },
        { score: 126, city_id: 2 },
        { score: 120, city_id: 3 }
      ]
    end

    it "ranks the cities properly" do
      expect(described_class.new(input).ranks).to match(
        [
          hash_including(id: 2, score: 126),
          hash_including(id: 1, score: 126),
          hash_including(id: 3, score: 120)
        ]
      )
    end

    it "uses non-dense ranking" do
      expect(described_class.new(input).ranks).to contain_exactly(
        hash_including(id: 2, rank: 1),
        hash_including(id: 1, rank: 1),
        hash_including(id: 3, rank: 3)
      )
    end
  end
end
