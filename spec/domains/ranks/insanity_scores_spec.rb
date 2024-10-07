# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ranks::InsanityScores do
  let(:pilou) { create :user, id: 1, username: "Pil0u" }
  let(:aquaj) { create :user, id: 2, username: "Aquaj" }
  let(:foo) { create :user, id: 3, username: "Foo" }

  let(:input) do
    [
      { score: 30, user_id: pilou.id },
      { score: 50, user_id: aquaj.id }
    ]
  end

  # Use a fixed time in the future to ensure positive durations
  let(:fake_now) { Time.new(2100, 1, 1, 0, 0, 0, Aoc.event_timezone) }

  it_behaves_like "a ranker"

  it "sorts by score" do
    expect(described_class.new(input).rank).to match([
                                                       input[1],
                                                       input[0]
                                                     ])
  end

  describe "when scores are tied" do
    let(:input) do
      [
        { score: 50, user_id: pilou.id },
        { score: 50, user_id: aquaj.id },
        { score: 50, user_id: foo.id }
      ]
    end

    context "and users have completed different numbers of puzzles" do
      it "the more completed puzzles the better" do
        create_list(:completion, 2, user: pilou)
        create_list(:completion, 3, user: aquaj)
        create_list(:completion, 1, user: foo)

        expect(described_class.new(input).rank).to eq([
                                                        input[1],
                                                        input[0],
                                                        input[2]
                                                      ])
      end
    end

    context "and users have completed the same puzzles, but took different times to complete them" do
      it "prioritizes by smaller total duration of puzzle solving" do
        create(:completion, user: pilou, day: 1, completion_unix_time: fake_now + 40.hours)
        create(:completion, user: aquaj, day: 1, completion_unix_time: fake_now + 20.hours)
        create(:completion, user: foo, day: 1, completion_unix_time: fake_now + 30.hours)

        expect(described_class.new(input).rank).to eq([
                                                        input[1],
                                                        input[2],
                                                        input[0]
                                                      ])
      end
    end

    context "and users have completed the same puzzles, took the same time to complete them" do
      it "prioritizes by user id" do
        create(:completion, user: pilou, day: 1, completion_unix_time: fake_now + 2.hours)
        create(:completion, user: aquaj, day: 1, completion_unix_time: fake_now + 2.hours)
        create(:completion, user: foo, day: 1, completion_unix_time: fake_now + 2.hours)

        expect(described_class.new(input).rank).to eq([
                                                        input[0],
                                                        input[1],
                                                        input[2]
                                                      ])
      end
    end
  end
end
