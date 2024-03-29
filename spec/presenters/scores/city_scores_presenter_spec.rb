# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::CityScoresPresenter do
  let!(:city_1) { create :city, id: 1, name: "Bordeaux", size: 200, top_contributors: 10 }
  let!(:city_2) { create :city, id: 2, name: "Rio de Janeiro", size: 100, top_contributors: 10 }
  let!(:city_3) { create :city, id: 3, name: "Paris", size: 500, top_contributors: 15 }

  let!(:user_1) { create :user, id: 1, city: city_1 }
  let!(:user_2) { create :user, id: 2, city: city_2 }
  let!(:user_3) { create :user, id: 3, city: city_1 }

  let(:input) do
    [
      {
        score: 125, city_id: 1,
        current_day_part_1_contributors: 3, current_day_part_2_contributors: 2,
        rank: 2, order: 2
      },
      {
        score: 126, city_id: 2,
        current_day_part_1_contributors: 4, current_day_part_2_contributors: 1,
        rank: 1, order: 1
      },
      {
        score: 0, city_id: 3,
        current_day_part_1_contributors: 2, current_day_part_2_contributors: 1,
        rank: 3, order: 3
      }
    ]
  end

  it "filters out campuses without any member" do
    expect(described_class.new(input).get.length).to eq 2
  end

  it "orders the cities based on order attribute" do
    expect(described_class.new(input).get).to match(
      [
        hash_including(id: 2, score: 126, rank: 1),
        hash_including(id: 1, score: 125, rank: 2)
      ]
    )
  end

  it "completes the campus info" do
    expect(described_class.new(input).get).to contain_exactly(
      hash_including(id: 1, vanity_name: "Bordeaux", slug: "bordeaux"),
      hash_including(id: 2, vanity_name: "Rio de Janeiro", slug: "rio-de-janeiro")
    )
  end

  it "completes the campus stats" do
    expect(described_class.new(input).get).to contain_exactly(
      hash_including(id: 1, total_members: 2, top_contributors: 10,
                     daily_contributors_part_1: 3, daily_contributors_part_2: 2),
      hash_including(id: 2, total_members: 1, top_contributors: 10,
                     daily_contributors_part_1: 4, daily_contributors_part_2: 1)
    )
  end
end
