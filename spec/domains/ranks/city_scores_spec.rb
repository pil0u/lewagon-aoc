require 'rails_helper'

RSpec.describe Ranks::CityScores do
  let(:bordeaux) { create :city, name: 'Bordeaux', size: 60 }
  let(:brussels) { create :city, name: 'Brussels', size: 10 }

  let(:input) { [
    { score: 50, city_id: bordeaux.id },
    { score: 30, city_id: brussels.id },
  ] }

  it_behaves_like "a ranker"

  it "sorts by score" do
    expect(described_class.new(input).rank).to match([
      input[0],
      input[1],
    ])
  end

  describe "in case of equality (first-level tie)" do
    let(:input) { [
      { score: 50, city_id: bordeaux.id },
      { score: 50, city_id: brussels.id },
    ] }

    let!(:completions) { [
      *create_list(:user, 11, city: bordeaux).map do |u|
        create(:completion, user: u, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 23.hours)
      end,
      *create_list(:user, 10, city: brussels).map do |u|
        create(:completion, user: u, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 23.hours)
      end
    ] }

    it "prioritizes the cities where the greatest percentage of top contributions were made under 24 hours" do
      expect(described_class.new(input).rank).to match([
        input[1], # Bordeaux has more completions but needs 12 contributions to max out
        input[0], # while Brussels only needs 10 to max out. 11/12 < 10/10
      ])
    end

    describe "in case of equality (second-level tie)" do
      let(:input) { [
        { score: 50, city_id: bordeaux.id },
        { score: 50, city_id: brussels.id },
      ] }

      let!(:completions) { [
        *create_list(:user, 12, city: bordeaux).map do |u|
          create(:completion, user: u, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 23.hours)
        end,
        *create_list(:user, 10, city: brussels).map do |u|
          create(:completion, user: u, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 23.hours)
        end,

        *create_list(:user, 11, city: bordeaux).map do |u|
          create(:completion, user: u, day: 1, challenge: 2, completion_unix_time: Aoc.begin_time + 40.hours)
        end,
        *create_list(:user, 9, city: brussels).map do |u|
          create(:completion, user: u, day: 1, challenge: 2, completion_unix_time: Aoc.begin_time + 40.hours)
        end
      ] }

      it "prioritizes the cities where the greatest percentage of top contributions were made under 48 hours" do
        expect(described_class.new(input).rank).to match([
          input[0], # 11 / 12 > 9 / 10
          input[1],
        ])
      end
    end
  end
end
