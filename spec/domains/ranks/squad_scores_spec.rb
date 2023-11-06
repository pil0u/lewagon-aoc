# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ranks::SquadScores do
  let(:foo_fighters) { create :squad, name: "Foo Fighters" }
  let(:kiss) { create :squad, name: "KISS" }

  let(:input) do
    [
      { score: 30, squad_id: kiss.id },
      { score: 50, squad_id: foo_fighters.id }
    ]
  end

  it_behaves_like "a ranker"

  it "sorts by score" do
    expect(described_class.new(input).rank).to match([
                                                       input[1],
                                                       input[0]
                                                     ])
  end

  describe "in case of equaltiy (first-level tie)" do
    let(:input) do
      [
        { score: 50, squad_id: kiss.id },
        { score: 50, squad_id: foo_fighters.id }
      ]
    end

    let!(:completions) do
      kiss_user = create(:user, squad: kiss)
      foo_user = create(:user, squad: foo_fighters)
      [
        create(:completion, day: 1, completion_unix_time: Aoc.begin_time + 23.hours, user: kiss_user),
        create(:completion, day: 1, completion_unix_time: Aoc.begin_time + 25.hours, user: foo_user)
      ]
    end

    it "prioritizes the squads who solved the most challenges in under 24hrs" do
      expect(described_class.new(input).rank).to match([
                                                         input[0],
                                                         input[1]
                                                       ])
    end

    context "in case of equality (third-level tie)" do
      let!(:completions) do
        kiss_user = create(:user, squad: kiss)
        foo_user = create(:user, squad: foo_fighters)

        [
          create(:completion, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 23.hours, user: kiss_user),
          create(:completion, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 23.hours, user: foo_user),

          create(:completion, day: 1, challenge: 2, completion_unix_time: Aoc.begin_time + 50.hours, user: kiss_user),
          create(:completion, day: 1, challenge: 2, completion_unix_time: Aoc.begin_time + 40.hours, user: foo_user)
        ]
      end

      it "prioritizes the squads who solved the most challenges in under 48hrs" do
        expect(described_class.new(input).rank).to match([
                                                           input[1],
                                                           input[0]
                                                         ])
      end
    end
  end
end
