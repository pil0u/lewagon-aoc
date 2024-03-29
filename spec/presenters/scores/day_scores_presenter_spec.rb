# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::DayScoresPresenter do
  let!(:user_1) do
    create :user,
           id: 1,
           username: "Saunier"
  end
  let!(:user_2) do
    create :user,
           id: 2,
           username: "pil0u"
  end

  let!(:completions) do
    [
      create(:completion, user: user_1, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 158),
      create(:completion, user: user_1, day: 1, challenge: 2, completion_unix_time: Aoc.begin_time + 265),
      create(:completion, user: user_1, day: 2, challenge: 1, completion_unix_time: Aoc.begin_time + 86_730),

      create(:completion, user: user_2, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 174),
      create(:completion, user: user_2, day: 2, challenge: 1, completion_unix_time: Aoc.begin_time + 86_938)
    ]
  end

  let(:input) do
    [
      { score: 99, rank: 1, order: 1, user_id: 1, day: 1,
        part_1_completion_id: completions[0].id, part_2_completion_id: completions[1].id },
      { score: 50, rank: 1, order: 1, user_id: 1, day: 2,
        part_1_completion_id: completions[2].id, part_2_completion_id: nil },
      { score: 25, rank: 2, order: 2, user_id: 2, day: 1,
        part_1_completion_id: completions[3].id, part_2_completion_id: nil },
      { score: 40, rank: 2, order: 2, user_id: 2, day: 2,
        part_1_completion_id: completions[4].id, part_2_completion_id: nil }
    ]
  end

  it "orders the users properly" do
    expect(described_class.new(input).get).to match(
      [
        hash_including(uid: "1", score: 99, day: 1),
        hash_including(uid: "1", score: 50, day: 2),
        hash_including(uid: "2", score: 25, day: 1),
        hash_including(uid: "2", score: 40, day: 2)
      ]
    )
  end

  it "completes the user info" do
    expect(described_class.new(input).get).to contain_exactly(
      hash_including(
        uid: "1",
        username: "Saunier"
      ),
      hash_including(
        uid: "2",
        username: "pil0u"
      ),
      hash_including(
        uid: "1",
        username: "Saunier"
      ),
      hash_including(
        uid: "2",
        username: "pil0u"
      )
    )
  end

  it "completes the user stats" do
    expect(described_class.new(input).get).to contain_exactly(
      hash_including(uid: "1", day: 1, part_1: 2.minutes + 38.seconds, part_2: 4.minutes + 25.seconds),
      hash_including(uid: "2", day: 1, part_1: 2.minutes + 54.seconds),
      hash_including(uid: "1", day: 2, part_1: 5.minutes + 30.seconds),
      hash_including(uid: "2", day: 2, part_1: 8.minutes + 58.seconds)
    )
  end
end
