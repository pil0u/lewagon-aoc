require 'rails_helper'

RSpec.describe Ranks::SoloScores do
  let(:pilou) { create :user, username: 'Pil0u' }
  let(:aquaj) { create :user, username: 'Aquaj' }

  let(:input) { [
    { score: 30, user_id: pilou.id },
    { score: 50, user_id: aquaj.id },
  ] }

  it_behaves_like "a ranker"

  it "sorts by score" do
    expect(described_class.new(input).rank).to match([
      input[1],
      input[0],
    ])
  end

  context "in case of equality (first-level tie)" do
    let(:input) { [
      { score: 50, user_id: pilou.id },
      { score: 50, user_id: aquaj.id },
    ] }

    let(:pilou) { create :user, username: 'Pil0u', entered_hardcore: false }
    let(:aquaj) { create :user, username: 'Aquaj', entered_hardcore: true }

    it "prioritizes non-hardcore players" do
      expect(described_class.new(input).rank).to match([
        input[0],
        input[1],
      ])
    end

    context "in case of equality (second-level tie)" do
      let(:pilou) { create :user, username: 'Pil0u', entered_hardcore: false }
      let(:aquaj) { create :user, username: 'Aquaj', entered_hardcore: false }

      let!(:existing_completions) { [
        create(:completion, user: pilou, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 25.hours),
        create(:completion, user: aquaj, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 20.hours),
      ] }

      it "prioritizes the users who solved the most challenges in under 24hrs" do
        expect(described_class.new(input).rank).to match([
          input[1],
          input[0],
        ])
      end

      context "in case of equality (third-level tie)" do
        let!(:existing_completions) { [
          create(:completion, user: pilou, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 20.hours),
          create(:completion, user: aquaj, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 20.hours),

          create(:completion, user: pilou, day: 1, challenge: 2, completion_unix_time: Aoc.begin_time + 40.hours),
          create(:completion, user: aquaj, day: 1, challenge: 2, completion_unix_time: Aoc.begin_time + 50.hours),
        ] }

        it "prioritizes the users who solved the most challenges in under 48hrs" do
          expect(described_class.new(input).rank).to match([
            input[0],
            input[1],
          ])
        end

        context "in case of equality (fourth-level tie)" do
          let!(:existing_completions) { [
            create(:completion, user: pilou, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 20.hours),
            create(:completion, user: aquaj, day: 1, challenge: 1, completion_unix_time: Aoc.begin_time + 20.hours),

            create(:completion, user: pilou, day: 1, challenge: 2, completion_unix_time: Aoc.begin_time + 40.hours),
            create(:completion, user: aquaj, day: 1, challenge: 2, completion_unix_time: Aoc.begin_time + 39.hours),
          ] }

          it "prioritizes the users who solved challenge in the less total time" do
            expect(described_class.new(input).rank).to match([
              input[1],
              input[0],
            ])
          end
        end
      end
    end
  end
end
