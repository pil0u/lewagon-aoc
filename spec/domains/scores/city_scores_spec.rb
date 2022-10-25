# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::CityScores do
  let!(:state) { create(:state) }

  let!(:bordeaux) { create(:city, name: "Bordeaux", id: 1, size: 80) }
  let!(:bordeaux_users) { create_list(:user, 8, city: bordeaux) { |u, i| u.aoc_id = i + 1 } }

  let!(:brussels) { create(:city, name: "Brussels", id: 2, size: 250) }
  let!(:brussels_users) { create_list(:user, 12, city: brussels) { |u, i| u.aoc_id = 100 + i + 1 } }

  let!(:paris) { create(:city, name: "Paris", id: 3, size: 400) }
  let!(:paris_users) { create_list(:user, 50, city: paris) { |u, i| u.aoc_id = 1000 + i + 1 } }

  let(:solo_scores) do
    [
      *bordeaux_users.map { |u| { user_id: u.id, score: u.aoc_id.even? ? 100 : 150 } },
      *brussels_users.map { |u| { user_id: u.id, score: u.aoc_id <= 110 ? 126 : 25 } },
      *paris_users.map    { |u| { user_id: u.id, score: u.aoc_id <= 1012 ? 120 : 110 } }
    ]
  end

  before do
    allow(Scores::SoloScores).to receive(:get).and_return(solo_scores).once
  end

  it "groups the scores of city members into the city score" do
    expect(described_class.get).to contain_exactly(
      { score: 100, city_id: 1 },
      { score: 126, city_id: 2 },
      { score: 120, city_id: 3 }
    )
  end

  context "when a city has a lot of alumni" do
    let!(:paris) { create(:city, name: "Paris", id: 3, size: 400) }
    let!(:paris_users) { create_list(:user, 50, city: paris) { |u, i| u.aoc_id = i + 1 } }

    let(:solo_scores) do
      [
        *paris_users[0...10].map { |u| { user_id: u.id, score: 120 } },
        *paris_users[10...20].map { |u| { user_id: u.id, score: 100 } },
        *paris_users[20...].map { |u| { user_id: u.id, score: 23 } }
      ]
    end

    # 3% == 12 for Paris (400 ppl)
    it "averages the top 3% of alumni scores" do
      theoretical_score = 117 # (120 * 10 + 100 * 2).to_f / 12 rounded up
      expect(described_class.get).to contain_exactly(
        { score: theoretical_score, city_id: 3 }
      )
    end
  end

  context "when a city doesn't have a lot of alumni" do
    let!(:brussels) { create(:city, name: "Brussels", id: 2, size: 250) }
    let!(:brussels_users) { create_list(:user, 12, city: brussels) { |u, i| u.aoc_id = i + 1 } }

    let(:solo_scores) do
      [
        *brussels_users[0...8].map { |u| { user_id: u.id, score: 150 } },
        *brussels_users[8...].map { |u| { user_id: u.id, score: 20 } }
      ]
    end

    # 3% == 8 for Brussels (250 ppl)
    it "averages the top 10 of alumni's scores" do
      theoretical_score = 124 # (150 * 8 + 20 * 2).to_f / 10 rounded up
      expect(described_class.get).to contain_exactly(
        { score: theoretical_score, city_id: 2 }
      )
    end
  end

  context "when a city doesn't have enough participants to fill its 'top' spots" do
    let!(:bordeaux) { create(:city, name: "Bordeaux", id: 1, size: 80) }
    let!(:bordeaux_users) { create_list(:user, 8, city: bordeaux) { |u, i| u.aoc_id = i + 1 } }

    let(:solo_scores) do
      [
        *bordeaux_users[0...4].map { |u| { user_id: u.id, score: 150 } },
        *bordeaux_users[4...].map { |u| { user_id: u.id, score: 100 } }
      ]
    end

    # 3% == 3 for Bordeaux (80 ppl), so eligible to Top 10 instead
    it "acts as if the missing scores were 0" do
      theoretical_score = 100 # (150 * 4 + 100 * 4 + 0 * 2).to_f / 10 rounded up
      expect(described_class.get).to contain_exactly(
        { score: theoretical_score, city_id: 1 }
      )
    end
  end

  describe "caching" do
    it "creates cache records on first call" do
      expect { described_class.get }.to(change { Cache::CityScore.count }.from(0).to(3))
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
          create(:state, fetch_api_begin: state.fetch_api_end + 2.seconds)
          allow(Scores::SoloScores).to receive(:get).and_return(new_solo_scores).once
        end

        let(:new_solo_scores) do
          [
            *bordeaux_users.map { |u| { user_id: u.id, score: u.aoc_id.even? ? 100 : 175 } },
            *brussels_users.map { |u| { user_id: u.id, score: u.aoc_id <= 110 ? 126 : 50 } },
            *paris_users.map    { |u| { user_id: u.id, score: u.aoc_id <= 1012 ? 145 : 110 } }
          ]
        end

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            { score: 110, city_id: 1 },
            { score: 126, city_id: 2 },
            { score: 145, city_id: 3 }
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to(change { Cache::CityScore.count }.from(3).to(6))
        end
      end

      context "when the users makeup of the city has changed in the meantime" do
        let(:new_bordeaux_users) { create_list :user, 2, city: bordeaux }

        before do
          travel 10.seconds # Specs go too fast, updated_at stays the same otherwise
          new_bordeaux_users # creating after travel
          allow(Scores::SoloScores).to receive(:get).and_return(new_solo_scores).once
        end

        let(:new_solo_scores) do
          [
            *new_bordeaux_users.map { |u| { user_id: u.id, score: 200 } },

            *bordeaux_users.map { |u| { user_id: u.id, score: u.aoc_id.even? ? 100 : 150 } },
            *brussels_users.map { |u| { user_id: u.id, score: u.aoc_id <= 110 ? 126 : 25 } },
            *paris_users.map    { |u| { user_id: u.id, score: u.aoc_id <= 1012 ? 120 : 110 } }
          ]
        end

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            { score: 140, city_id: 1 },
            { score: 126, city_id: 2 },
            { score: 120, city_id: 3 }
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to(change { Cache::CityScore.count }.from(3).to(6))
        end
      end
    end
  end
end
