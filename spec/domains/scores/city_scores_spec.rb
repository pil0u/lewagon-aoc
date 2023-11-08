# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::CityScores do
  let(:state) { create(:state, completions_fetched: 6, fetch_api_end: Time.zone.now) }

  let(:bordeaux) { create :city, name: "Bordeaux", size: 10 }
  let(:bordeaux_batch) { create(:batch, number: 1, city: bordeaux) }
  let(:brussels) { create :city, name: "Brussels", size: 10 }
  let(:brussels_batch) { create(:batch, number: 2, city: brussels) }
  let(:city_points) do
    [
      { day: 1, challenge: 1, city_id: brussels.id, contributor_count: 2, total_score: 96, score: 8.00 },
      { day: 1, challenge: 2, city_id: brussels.id, contributor_count: 1, total_score: 48, score: 4.00 },
      { day: 2, challenge: 1, city_id: brussels.id, contributor_count: 2, total_score: 78, score: 6.50 },

      { day: 1, challenge: 1, city_id: bordeaux.id, contributor_count: 1, total_score: 50, score: 5.00 }
    ]
  end

  before do
    freeze_time
    allow(Aoc).to receive(:latest_day).and_return(2)
    allow(Scores::CityPoints).to receive(:get).and_return(city_points).once
  end

  it "sums the challenge scores into a total score for each city" do
    expect(described_class.get).to contain_exactly(
      hash_including(city_id: brussels.id, score: 19),
      hash_including(city_id: bordeaux.id, score: 5)
    )
  end

  it "return the number of contributors for each part of the current day" do
    expect(described_class.get).to contain_exactly(
      hash_including(city_id: brussels.id, current_day_part_1_contributors: 2, current_day_part_2_contributors: 0),
      hash_including(city_id: bordeaux.id, current_day_part_1_contributors: 0, current_day_part_2_contributors: 0)
    )
  end

  it "ranks the scores" do
    expect(Ranks::CityScores).to receive(:rank_and_number).and_call_original
    described_class.get
  end

  describe "caching" do
    it "creates cache records on first call" do
      expect { described_class.get }.to(change { Cache::CityScore.count }.from(0).to(2))
    end

    context "on second call" do
      before do
        described_class.get
      end

      it "doesn't re-create cache" do
        expect { described_class.get }.not_to(change { Cache::CityScore.count })
      end

      it "doesn't do any computation" do
        expect_any_instance_of(described_class).not_to receive(:compute)
        described_class.get
      end

      context "when AOC state has been refetched in the meantime" do
        before do
          travel 10.seconds
          create(:state, fetch_api_begin: Time.zone.now, completions_fetched: 1)
          allow(Scores::CityPoints).to receive(:get).and_return(new_city_points)
        end

        let(:new_city_points) do
          [
            *city_points,
            { day: 1, challenge: 2, city_id: bordeaux.id, contributor_count: 1, total_score: 50, score: 5.00 }
          ]
        end

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            hash_including(city_id: brussels.id, score: 19),
            hash_including(city_id: bordeaux.id, score: 10)
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to(change { Cache::CityScore.count }.from(2).to(4))
        end
      end

      context "when the users makeup of the city has changed in the meantime" do
        before do
          travel 10.seconds # Specs go too fast, updated_at stays the same otherwise
          create(:state, fetch_api_begin: Time.zone.now, completions_fetched: 1)
          create_list :user, 2, batch: bordeaux_batch # creating after travel
          allow(Scores::CityPoints).to receive(:get).and_return(new_city_points)
        end

        let(:new_city_points) do
          [
            *city_points,
            { day: 1, challenge: 2, city_id: bordeaux.id, contributor_count: 1, total_score: 50, score: 5.00 }
          ]
        end

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            hash_including(city_id: brussels.id, score: 19),
            hash_including(city_id: bordeaux.id, score: 10)
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to(change { Cache::CityScore.count }.from(2).to(4))
        end
      end
    end
  end
end
