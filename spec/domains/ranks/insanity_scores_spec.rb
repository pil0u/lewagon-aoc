require 'rails_helper'

RSpec.describe Ranks::InsanityScores do
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

  describe "tie-breaking" do

    let(:input) { [
      { score: 50, user_id: pilou.id },
      { score: 50, user_id: aquaj.id },
    ] }

    let!(:completions) { [
      create(:completion, user: aquaj, day: 1, completion_unix_time: Aoc.begin_time + 20.hours),
      create(:completion, user: pilou, day: 1, completion_unix_time: Aoc.begin_time + 10.hours),
    ] }

    it "prioritizes shorter completion times" do
      expect(described_class.new(input).rank).to match([
        input[0],
        input[1],
      ])
    end
  end
end
