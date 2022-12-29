# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "a ranker" do
  let(:input) do
    [
      { id: 1, score: 2 },
      { id: 2, score: 8 },
      { id: 3, score: 4 },
      { id: 4, score: 6 }
    ]
  end

  let(:ranker) { described_class.new(input) }

  before do
    allow(ranker).to receive(:ranking_criterion) do |record|
      [record[:score], record[:id]]
    end
  end

  it "orders the elements of the collection based on #ranking_criterion" do
    expect(ranker.number).to match([
                                     hash_including(id: 2),
                                     hash_including(id: 4),
                                     hash_including(id: 3),
                                     hash_including(id: 1)
                                   ])
  end

  it "numbers the collection with their rank" do
    expect(ranker.number).to match([
                                     hash_including(id: 2, rank: 1),
                                     hash_including(id: 4, rank: 2),
                                     hash_including(id: 3, rank: 3),
                                     hash_including(id: 1, rank: 4)
                                   ])
  end

  it "numbers the collection with a complete ordering" do
    expect(ranker.number).to match([
                                     hash_including(id: 2, order: 0),
                                     hash_including(id: 4, order: 1),
                                     hash_including(id: 3, order: 2),
                                     hash_including(id: 1, order: 3)
                                   ])
  end

  context "in case of score equality" do
    let(:input) do
      [
        { id: 1, score: 2 },
        { id: 2, score: 8 },
        { id: 3, score: 4 },
        { id: 4, score: 4 }
      ]
    end

    it "uses non-dense ranking" do
      expect(ranker.number).to match([
                                       hash_including(id: 2, rank: 1),
                                       hash_including(id: 4, rank: 2),
                                       hash_including(id: 3, rank: 2),
                                       hash_including(id: 1, rank: 4)
                                     ])
    end

    it "still numbers the collection with a complete ordering" do
      expect(ranker.number).to match([
                                       hash_including(id: 2, order: 0),
                                       hash_including(id: 4, order: 1),
                                       hash_including(id: 3, order: 2),
                                       hash_including(id: 1, order: 3)
                                     ])
    end
  end
end
