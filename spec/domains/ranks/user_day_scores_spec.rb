# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ranks::UserDayScores do
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

  context "in case of equality (first-level tie)" do
    let(:input) do
      [
        { score: 50, user_id: pilou.id, part_1_completion_id: completions[0].id },
        { score: 50, user_id: aquaj.id, part_1_completion_id: completions[1].id }
      ]
    end

    let(:pilou) { create :user, username: "Pil0u" }
    let(:aquaj) { create :user, username: "Aquaj" }

    let!(:completions) { [
      create(:completion, user: pilou, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 1.hour),
      create(:completion, user: aquaj, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 2.hour),
    ] }

    it "prioritizes players that have completed part 1 the fastest" do
      expect(described_class.new(input).rank).to match([
                                                         input[0],
                                                         input[1]
                                                       ])
    end


    context "in case of equality (second-level tie)" do
      let(:pilou) { create :user, username: "Pil0u", entered_hardcore: false }
      let(:aquaj) { create :user, username: "Aquaj", entered_hardcore: false }

      let(:input) do
        [
          {
            score: 50, user_id: pilou.id,
            part_1_completion_id: completions[0].id, part_2_completion_id: completions[2].id
          },
          {
            score: 50, user_id: aquaj.id,
            part_1_completion_id: completions[1].id, part_2_completion_id: completions[3].id
          }
        ]
      end

      let!(:completions) { [
        create(:completion, user: pilou, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 1.hour),
        create(:completion, user: aquaj, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 1.hour),

        create(:completion, user: pilou, day: 1, challenge: 2, completion_unix_time: Aoc.begin_time + 2.hour),
        create(:completion, user: aquaj, day: 1, challenge: 2, completion_unix_time: Aoc.begin_time + 1.hour),
      ] }

    it "prioritizes players that have completed part 2 the fastest" do
        expect(described_class.new(input).rank).to match([
                                                           input[1],
                                                           input[0]
                                                         ])
      end
    end
  end
end
