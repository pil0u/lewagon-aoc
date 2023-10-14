# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::UserScoresPresenter do
  let!(:paris) { create :city, name: "Paris" }
  let!(:bordeaux) { create :city, name: "Bordeaux" }
  let!(:squad_1) { create :squad, name: "The Killers" }
  let!(:squad_2) { create :squad, name: "Grouplove" }
  let!(:batch_1) { create :batch, number: 1 }
  let!(:batch_2) { create :batch, number: 2 }
  let!(:batch_3) { create :batch, number: 3 }

  let!(:user_1) do
    create :user,
           id: 1,
           username: "Saunier",
           city: paris,
           squad: squad_1,
           batch: batch_1,
           entered_hardcore: false
  end
  let!(:user_2) do
    create :user,
           id: 2,
           username: "pil0u",
           city: bordeaux,
           squad: squad_2,
           batch: batch_2,
           entered_hardcore: true
  end

  let!(:completions) do
    create :completion, user: user_1, day: 1, challenge: 1, completion_unix_time: 1
    create :completion, user: user_1, day: 1, challenge: 2, completion_unix_time: 1
    create :completion, user: user_1, day: 2, challenge: 1, completion_unix_time: 1
    create :completion, user: user_1, day: 2, challenge: 2, completion_unix_time: 1
    create :completion, user: user_1, day: 3, challenge: 1, completion_unix_time: 1

    create :completion, user: user_2, day: 1, challenge: 1, completion_unix_time: 1
    create :completion, user: user_2, day: 1, challenge: 2, completion_unix_time: 1
    create :completion, user: user_2, day: 2, challenge: 1, completion_unix_time: 1
    create :completion, user: user_2, day: 2, challenge: 2, completion_unix_time: 1
    create :completion, user: user_2, day: 3, challenge: 1, completion_unix_time: 1
    create :completion, user: user_2, day: 3, challenge: 2, completion_unix_time: 1
  end

  let(:input) do
    [
      { score: 99, user_id: 1, current_day_score: 50, rank: 1, order: 1 },
      { score: 25, user_id: 2, current_day_score: 40, rank: 2, order: 2 }
    ]
  end

  it "sorts the users based on the order attribute" do
    expect(described_class.new(input).get).to match(
      [
        hash_including(uid: 1, score: 99, rank: 1),
        hash_including(uid: 2, score: 25, rank: 2)
      ]
    )
  end

  it "completes the user info" do
    expect(described_class.new(input).get).to contain_exactly(
      hash_including(
        uid: 1,
        username: "Saunier",
        city_name: "Paris",
        batch_number: 1,
        squad_name: "The Killers",
        entered_hardcore: false
      ),
      hash_including(
        uid: 2,
        username: "pil0u",
        city_name: "Bordeaux",
        batch_number: 2,
        squad_name: "Grouplove",
        entered_hardcore: true
      )
    )
  end

  it "completes the user stats" do
    expect(described_class.new(input).get).to contain_exactly(
      hash_including(
        uid: 1,
        silver_stars: 1,
        gold_stars: 2,
        daily_score: 50
      ),
      hash_including(
        uid: 2,
        username: "pil0u",
        silver_stars: 0,
        gold_stars: 3,
        daily_score: 40
      )
    )
  end

  context "in case of equality" do
    let!(:user_3) { create :user, id: 3 }

    let(:input) do
      [
        { score: 99, user_id: 1, rank: 1, order: 1 },
        { score: 25, user_id: 2, rank: 3, order: 3 },
        { score: 99, user_id: 3, rank: 1, order: 2 }
      ]
    end

    it "orders the users properly" do
      expect(described_class.new(input).get).to match(
        [
          hash_including(uid: 1, score: 99),
          hash_including(uid: 3, score: 99),
          hash_including(uid: 2, score: 25)
        ]
      )
    end
  end

  context "when user has not completed any challenge" do
    let!(:user_3) { create :user, id: 3 }

    let(:input) do
      [
        { score: 99, user_id: 1 },
        { score: 25, user_id: 2 },
        { score: 0, user_id: 3 }
      ]
    end

    it "has no stars" do
      expect(described_class.new(input).get).to include(
        hash_including(uid: 3, silver_stars: 0, gold_stars: 0)
      )
    end
  end

  context "when user has no squad" do
    before do
      user_1.update!(squad: nil)
    end

    it "includes no info about it in the output" do
      expect(described_class.new(input).get).to include(
        hash_including(uid: 1, squad_name: nil)
      )
    end
  end

  context "when user has no city" do
    before do
      user_1.update!(city: nil)
    end

    it "includes no info about it in the output" do
      expect(described_class.new(input).get).to include(
        hash_including(uid: 1, city_name: nil)
      )
    end
  end

  context "when user has no batch" do
    before do
      user_1.update!(batch: nil)
    end

    it "includes no info about it in the output" do
      expect(described_class.new(input).get).to include(
        hash_including(uid: 1, batch_number: nil)
      )
    end
  end
end
