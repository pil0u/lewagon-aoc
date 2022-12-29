require 'rails_helper'

RSpec.describe Ranks::CityScores do
  let(:bordeaux) { create :city, name: 'Bordeaux', size: 1 }
  let(:brussels) { create :city, name: 'Brussels', size: 2 }
  let(:remote) { create :city, name: 'Remote', size: 1 }

  let(:input) { [
    { score: 50, city_id: bordeaux.id },
    { score: 30, city_id: brussels.id },
    { score: 40, city_id: remote.id },
  ] }

  it_behaves_like "a ranker"

  it "sorts by score" do
    expect(described_class.new(input).rank).to match([
      input[0],
      input[2],
      input[1],
    ])
  end

  describe "first-level tie-breaking" do
    let(:input) { [
      { score: 50, city_id: bordeaux.id },
      { score: 50, city_id: brussels.id },
    ] }

    pending "Not clarified yet"
  end

  describe "second-level tie-breaking" do
    let(:input) { [
      { score: 50, city_id: bordeaux.id },
      { score: 50, city_id: brussels.id },
    ] }

    pending "Not clarified yet"
  end
end
