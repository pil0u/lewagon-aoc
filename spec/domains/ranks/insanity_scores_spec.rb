# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ranks::InsanityScores do
  let(:pilou) { create :user, username: "Pil0u" }
  let(:aquaj) { create :user, username: "Aquaj" }

  let(:input) do
    [
      { score: 30, user_id: pilou.id },
      { score: 50, user_id: aquaj.id }
    ]
  end

  it_behaves_like "a ranker"

  it "sorts by score" do
    expect(described_class.new(input).rank).to match([
                                                       input[1],
                                                       input[0]
                                                     ])
  end

  describe "tie-breaking" do
    let(:input) do
      [
        { score: 50, user_id: pilou.id },
        { score: 50, user_id: aquaj.id }
      ]
    end

    let!(:completions) do
      [
        create(:completion, user: aquaj, day: 1, completion_unix_time: Aoc.begin_time + 20.hours),
        create(:completion, user: pilou, day: 1, completion_unix_time: Aoc.begin_time + 10.hours)
      ]
    end

    it "prioritizes shorter completion times" do
      expect(described_class.new(input).rank).to match([
                                                         input[0],
                                                         input[1]
                                                       ])
    end
  end
end
