# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::CityPoints do
  let!(:state) { create :state, completions_fetched: solo_points.count, fetch_api_end: Time.zone.now }
  let(:brussels) { create(:city, name: "Brussels", size: 400) }
  let(:brussels_users) { create_list(:user, 18, city: brussels) }
  let(:brussels_points) do
    [
      { day: 1, challenge: 1, score: 50, user_id: brussels_users[0].id },
      { day: 1, challenge: 2, score: 48, user_id: brussels_users[0].id },
      { day: 2, challenge: 1, score: 30, user_id: brussels_users[0].id },

      { day: 1, challenge: 1, score: 46, user_id: brussels_users[1].id },
      { day: 2, challenge: 1, score: 48, user_id: brussels_users[1].id }
    ]
  end

  let(:bordeaux) { create(:city, name: "Bordeaux", size: 400) }
  let(:bordeaux_users) { create_list(:user, 18, city: bordeaux) }
  let(:bordeaux_points) do
    [
      { day: 1, challenge: 1, score: 46, user_id: bordeaux_users[0].id }
    ]
  end

  let(:solo_points) { [*brussels_points, *bordeaux_points] }

  before do
    allow(Scores::SoloPoints).to receive(:get).and_return(solo_points).once
  end

  it "computes the number of contributions for each challenge and city" do
    expect(described_class.get).to contain_exactly(
      hash_including(day: 1, challenge: 1, city_id: brussels.id, contributor_count: 2),
      hash_including(day: 1, challenge: 2, city_id: brussels.id, contributor_count: 1),
      hash_including(day: 2, challenge: 1, city_id: brussels.id, contributor_count: 2),
      hash_including(day: 1, challenge: 1, city_id: bordeaux.id, contributor_count: 1)
    )
  end

  it "computes the total score for each challenge" do
    expect(described_class.get).to contain_exactly(
      hash_including(day: 1, challenge: 1, city_id: brussels.id, total_score: 96),
      hash_including(day: 1, challenge: 2, city_id: brussels.id, total_score: 48),
      hash_including(day: 2, challenge: 1, city_id: brussels.id, total_score: 78),
      hash_including(day: 1, challenge: 1, city_id: bordeaux.id, total_score: 46)
    )
  end

  context "when a city has a lot of alumni" do
    let(:solo_points) do
      [
        *brussels_points,

        { day: 3, challenge: 1, score: 30, user_id: brussels_users[0].id },
        { day: 3, challenge: 1, score: 30, user_id: brussels_users[1].id },
        { day: 3, challenge: 1, score: 30, user_id: brussels_users[2].id },
        { day: 3, challenge: 1, score: 30, user_id: brussels_users[3].id },
        { day: 3, challenge: 1, score: 30, user_id: brussels_users[4].id },
        { day: 3, challenge: 1, score: 30, user_id: brussels_users[5].id },
        { day: 3, challenge: 1, score: 30, user_id: brussels_users[6].id },
        { day: 3, challenge: 1, score: 30, user_id: brussels_users[7].id },
        { day: 3, challenge: 1, score: 30, user_id: brussels_users[8].id },
        { day: 3, challenge: 1, score: 30, user_id: brussels_users[9].id },
        { day: 3, challenge: 1, score: 30, user_id: brussels_users[10].id },
        { day: 3, challenge: 1, score: 30, user_id: brussels_users[11].id },
        { day: 3, challenge: 1, score: 30, user_id: brussels_users[12].id },
        { day: 3, challenge: 1, score: 30, user_id: brussels_users[13].id }
      ]
    end

    before do
      brussels.update!(size: 380)
    end

    # 3% == 11.4 -> 12 for size == 380
    it "averages the top 3% of alumni scores for each challenge" do
      expect(described_class.get).to contain_exactly(
        # (50 + 46).to_f / (380 * .03)
        hash_including(day: 1, challenge: 1, city_id: brussels.id, total_score: 96, score: 8.00, contributor_count: 2),
        # (48).to_f / (380 * .03)
        hash_including(day: 1, challenge: 2, city_id: brussels.id, total_score: 48, score: 4.00, contributor_count: 1),
        # (30 + 48).to_f / (380 * .03)
        hash_including(day: 2, challenge: 1, city_id: brussels.id, total_score: 78, score: 6.50, contributor_count: 2),
        # (20 * 12).to_f / (380 * .03) -- checks we're properly limiting the sum to the top N
        hash_including(day: 3, challenge: 1, city_id: brussels.id, total_score: 360, score: 30, contributor_count: 14)
      )
    end
  end

  context "when a city doesn't have a lot of alumni" do
    let(:solo_points) { brussels_points }

    before do
      brussels.update!(size: 80)
    end

    # 3% == 2.4 -> 3 for size == 80
    it "averages the top 10 alumni scores for each challenge" do
      expect(described_class.get).to contain_exactly(
        # (50 + 46).to_f / 10
        { day: 1, challenge: 1, city_id: brussels.id, total_score: 96, score: 9.60, contributor_count: 2 },
        # (48).to_f / 10
        { day: 1, challenge: 2, city_id: brussels.id, total_score: 48, score: 4.80, contributor_count: 1 },
        # (30 + 48).to_f / 10
        { day: 2, challenge: 1, city_id: brussels.id, total_score: 78, score: 7.80, contributor_count: 2 }
      )
    end
  end

  describe "caching" do
    it "creates cache records on first call" do
      expect { described_class.get }.to(change { Cache::CityPoint.count }.from(0).to(4))
    end

    context "on second call" do
      before do
        described_class.get
      end

      it "doesn't re-create cache" do
        expect { described_class.get }.not_to(change { Cache::CityPoint.count })
      end

      it "doesn't do any computation" do
        expect_any_instance_of(described_class).not_to receive(:compute)
        described_class.get
      end

      context "when AOC state has been refetched in the meantime" do
        before do
          create(:state, fetch_api_begin: state.fetch_api_end + 2.seconds)
          allow(Scores::SoloPoints).to receive(:get).and_return(new_solo_points)
        end

        let(:new_solo_points) do
          [
            *solo_points,
            { day: 1, challenge: 1, score: 40, user_id: bordeaux_users[2].id }
          ]
        end

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            hash_including(day: 1, challenge: 1, city_id: brussels.id, contributor_count: 2, total_score: 96),
            hash_including(day: 1, challenge: 2, city_id: brussels.id, contributor_count: 1, total_score: 48),
            hash_including(day: 2, challenge: 1, city_id: brussels.id, contributor_count: 2, total_score: 78),
            hash_including(day: 1, challenge: 1, city_id: bordeaux.id, contributor_count: 2, total_score: 86)
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to(change { Cache::CityPoint.count }.from(4).to(8))
        end
      end

      context "when the users makeup of the city has changed in the meantime" do
        let(:new_bordeaux_users) { create_list :user, 2, city: bordeaux }

        before do
          travel 10.seconds # Specs go too fast, updated_at stays the same otherwise
          create(:state, completions_fetched: 1, fetch_api_end: Time.zone.now) # simulate new fetch
          new_bordeaux_users # creating after travel
          allow(Scores::SoloPoints).to receive(:get).and_return(new_solo_scores)
        end

        let(:new_solo_scores) do
          [
            *solo_points,
            { day: 1, challenge: 1, score: 40, user_id: new_bordeaux_users[0].id }
          ]
        end

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            hash_including(day: 1, challenge: 1, city_id: brussels.id, contributor_count: 2, total_score: 96),
            hash_including(day: 1, challenge: 2, city_id: brussels.id, contributor_count: 1, total_score: 48),
            hash_including(day: 2, challenge: 1, city_id: brussels.id, contributor_count: 2, total_score: 78),
            hash_including(day: 1, challenge: 1, city_id: bordeaux.id, contributor_count: 2, total_score: 86)
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to(change { Cache::CityPoint.count }.from(4).to(8))
        end
      end
    end
  end
end
