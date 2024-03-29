# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::SquadScores do
  let!(:state) { create(:state) }

  let!(:squad_1) { create(:squad, id: 1) }
  let!(:squad_2) { create(:squad, id: 2) }
  let!(:squad_3) { create(:squad, id: 3) }

  let(:squad_points) do
    [
      { score: 53, squad_id: 1, day: 1, challenge: 1 },
      { score: 25, squad_id: 1, day: 1, challenge: 2 },
      { score: 60, squad_id: 1, day: 2, challenge: 1 },
      { score: 50, squad_id: 2, day: 1, challenge: 1 },
      { score: 50, squad_id: 2, day: 1, challenge: 2 },
      { score: 40, squad_id: 2, day: 2, challenge: 1 }
    ]
  end

  before do
    allow(Aoc).to receive(:latest_day).and_return(2)
    allow(Scores::SquadPoints).to receive(:get).and_return(squad_points).once
  end

  it "groups the scores of squad members into the squad score" do
    expect(described_class.get).to contain_exactly(
      hash_including(score: 138, squad_id: 1),
      hash_including(score: 140, squad_id: 2)
    )
  end

  it "includes the score of the current day" do
    expect(described_class.get).to contain_exactly(
      hash_including(current_day_score: 60, squad_id: 1),
      hash_including(current_day_score: 40, squad_id: 2)
    )
  end

  it "ranks the scores" do
    expect(Ranks::SquadScores).to receive(:rank_and_number).and_call_original
    described_class.get
  end

  context "when a squad has no point for the day" do
    before do
      squad_points.delete(
        squad_points.find { |score| score[:day] == 2 && score[:squad_id] == 2 }
      )
    end

    it "sets their score of the day to 0" do
      expect(described_class.get).to include(
        hash_including(current_day_score: 0, squad_id: 2)
      )
    end
  end

  describe "caching" do
    it "creates cache records on first call" do
      expect { described_class.get }.to change(Cache::SquadScore, :count).from(0).to(2)
    end

    context "on second call" do
      before do
        described_class.get
      end

      it "doesn't re-create cache" do
        expect { described_class.get }.not_to change(Cache::SquadScore, :count)
      end

      it "doesn't do any computation" do
        expect_any_instance_of(described_class).not_to receive(:compute)
        described_class.get
      end

      context "when AOC state has been refetched in the meantime" do
        before do
          create(:state, fetch_api_begin: state.fetch_api_end + 2.seconds)
          allow(Scores::SquadPoints).to receive(:get).and_return(new_squad_points).once
        end

        let(:new_squad_points) do
          [
            { score: 53, squad_id: 1, day: 1, challenge: 1 },
            { score: 25, squad_id: 1, day: 1, challenge: 2 },
            { score: 70, squad_id: 1, day: 2, challenge: 1 },
            { score: 50, squad_id: 2, day: 1, challenge: 1 },
            { score: 50, squad_id: 2, day: 1, challenge: 2 },
            { score: 60, squad_id: 2, day: 2, challenge: 1 }
          ]
        end

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            hash_including(score: 148, squad_id: 1, current_day_score: 70),
            hash_including(score: 160, squad_id: 2, current_day_score: 60)
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to change(Cache::SquadScore, :count).from(2).to(4)
        end
      end

      context "when the users makeup of the squad has changed in the meantime" do
        before do
          travel 10.seconds # Specs go too fast, updated_at stays the same otherwise
          create(:user, squad: squad_3)
          allow(Scores::SquadPoints).to receive(:get).and_return(new_squad_points).once
        end

        let(:new_squad_points) do
          [
            { score: 53, squad_id: 1, day: 1, challenge: 1 },
            { score: 25, squad_id: 1, day: 1, challenge: 2 },
            { score: 70, squad_id: 1, day: 2, challenge: 1 },
            { score: 30, squad_id: 2, day: 1, challenge: 1 },
            { score: 30, squad_id: 2, day: 1, challenge: 2 },
            { score: 50, squad_id: 2, day: 2, challenge: 1 },
            { score: 20, squad_id: 3, day: 1, challenge: 1 },
            { score: 20, squad_id: 3, day: 1, challenge: 2 },
            { score: 10, squad_id: 3, day: 2, challenge: 1 }
          ]
        end

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            hash_including(score: 148, squad_id: 1, current_day_score: 70),
            hash_including(score: 110, squad_id: 2, current_day_score: 50),
            hash_including(score: 50, squad_id: 3, current_day_score: 10)
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to change(Cache::SquadScore, :count).from(2).to(5)
        end
      end

      context "when we moved to a new AoC day" do
        before do
          allow(Aoc).to receive(:latest_day).and_return(3)
          allow(Scores::SquadPoints).to receive(:get).and_return(squad_points)
        end

        it "doesn't provide stale results" do
          expect(described_class.get).to contain_exactly(
            hash_including(squad_id: 1, current_day_score: 0),
            hash_including(squad_id: 2, current_day_score: 0)
          )
        end

        it "recomputes" do
          expect_any_instance_of(described_class).to receive(:compute).and_call_original
          described_class.get
        end

        it "creates new cache records" do
          expect { described_class.get }.to change(Cache::SquadScore, :count).from(2).to(4)
        end
      end
    end
  end
end
