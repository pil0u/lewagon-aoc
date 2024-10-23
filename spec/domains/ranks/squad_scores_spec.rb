# frozen_string_literal: true

require "rails_helper"

RSpec.describe Ranks::SquadScores do
  let(:foo_fighters) { create :squad, name: "Foo Fighters" }
  let(:kiss) { create :squad, name: "KISS" }
  let(:pnl) { create :squad, name: "PNL" }

  let(:kiss_user) { create :user, username: "Kissman", squad: kiss }
  let(:foo_user) { create :user, username: "Foobarman", squad: foo_fighters }
  let(:pnl_user) { create :user, username: "Ademo", squad: pnl }

  let(:input) do
    [
      { score: 10, squad_id: kiss.id },
      { score: 50, squad_id: foo_fighters.id },
      { score: 99, squad_id: pnl.id }
    ]
  end

  it_behaves_like "a ranker"

  it "sorts the squads by highest number of stars" do
    # kiss = 1 star
    create(:completion, day: 1, challenge: 1, user: kiss_user)
    # foo = 3 stars
    create(:completion, day: 1, challenge: 1, user: foo_user)
    create(:completion, day: 1, challenge: 2, user: foo_user)
    create(:completion, day: 2, challenge: 1, user: foo_user)
    # pnl = 2 stars
    create(:completion, day: 1, challenge: 1, user: pnl_user)
    create(:completion, day: 1, challenge: 2, user: pnl_user)

    expect(described_class.new(input).rank).to match([
                                                       input[1],
                                                       input[2],
                                                       input[0]
                                                     ])
  end

  describe "in case of equal number of stars (first-level tie)" do
    it "prioritizes the squads who have the least number of users" do
      # Create 3 stars for each squad, materialise 1 user user in each squad
      create(:completion, day: 1, challenge: 1, user: kiss_user)
      create(:completion, day: 1, challenge: 1, user: foo_user)
      create(:completion, day: 1, challenge: 1, user: pnl_user)

      # Create 1 additional user in a squad and 2 in another
      create(:user, username: "Kissman2", squad: kiss)
      create(:user, username: "Kissman3", squad: kiss)
      create(:user, username: "NOS", squad: pnl)

      expect(described_class.new(input).rank).to match([
                                                         input[1],
                                                         input[2],
                                                         input[0]
                                                       ])
    end
  end

  describe "in case of equal number of users (second-level tie)" do
    it "prioritizes the squads with the highest score" do
      # Same number of stars (3), same number of users per squad (1)
      create(:completion, day: 1, challenge: 1, user: kiss_user)
      create(:completion, day: 1, challenge: 1, user: foo_user)
      create(:completion, day: 1, challenge: 1, user: pnl_user)

      expect(described_class.new(input).rank).to match([
                                                         input[2],
                                                         input[1],
                                                         input[0]
                                                       ])
    end
  end
end
