# frozen_string_literal: true

require "rails_helper"

RSpec.describe Completions::Fetcher do
  let!(:aquaj) { create :user, aoc_id: 151_323 }
  let!(:denis) { create :user, aoc_id: 1_675_967 }

  before do
    allow(Aoc).to receive(:private_leaderboards).and_return(["123-7ae33"])
    stub_aoc_call
  end

  def stub_aoc_call
    allow(ENV).to receive(:fetch).with("SESSION_COOKIE").and_return("eyJH==")
    stub_request(:get, /adventofcode.com.*\d+.json/).to_return do |req|
      # dynamic fetching of the fixture depending on the id passed for the call
      id = req.uri.path.match(/\w+.json$/)
      { body: file_fixture("leaderboard_completions-#{id}") }
    end
  end

  it "creates a State based on the fetch" do
    expect { described_class.call }.to change { State.count }.by(1)
  end

  describe "created State" do
    subject { described_class.call; State.last }

    it "should log the completion start and end times" do
      expect(subject.attributes).to match(hash_including(
        fetch_api_begin: a_kind_of(DateTime), fetch_api_end: a_kind_of(DateTime)
      ))
    end

    it "should keep track of how many completions were created during the refresh" do
      expect(subject.attributes).to match(hash_including(completions_fetched: 8))
    end

    context "when there are no new completions" do
      subject { described_class.call; described_class.call;  State.last }

      it "should keep note that 0 completions were created" do
        expect(subject.attributes).to match(hash_including(completions_fetched: 8))
      end
    end
  end

  it "creates completions for each user in the leaderboard" do
    expect { described_class.call }
      .to change { aquaj.completions.count }.from(0).to(8)
      .and change { denis.completions.count }.from(0).to(6)
  end

  it "creates the completions with the appropriate data" do
    described_class.call
    expect(aquaj.completions.map(&:attributes).map(&:symbolize_keys)).to contain_exactly(
      hash_including(day: 1, challenge: 1, completion_unix_time: 1_669_918_804),
      hash_including(day: 1, challenge: 2, completion_unix_time: 1_669_918_892),
      hash_including(day: 2, challenge: 1, completion_unix_time: 1_669_958_282),
      hash_including(day: 2, challenge: 2, completion_unix_time: 1_669_959_061),
      hash_including(day: 3, challenge: 1, completion_unix_time: 1_670_043_972),
      hash_including(day: 3, challenge: 2, completion_unix_time: 1_670_044_230),
      hash_including(day: 4, challenge: 1, completion_unix_time: 1_670_130_271),
      hash_including(day: 4, challenge: 2, completion_unix_time: 1_670_130_339)
    )
  end

  context "when this is the first time we see the user on the leaderboard" do
    before do
      denis.update!(synced: false)
    end

    it "marks the user as synced" do
      expect { described_class.call }.to change { denis.reload.synced }.from(false).to(true)
    end
  end

  context "when we already know some of the completions" do
    let!(:existing_completions) do
      [
        create(:completion, day: 1, challenge: 1, completion_unix_time: 1_669_918_804, user: aquaj),
        create(:completion, day: 1, challenge: 2, completion_unix_time: 1_669_918_892, user: aquaj),
        create(:completion, day: 2, challenge: 1, completion_unix_time: 1_669_958_282, user: aquaj),
        create(:completion, day: 2, challenge: 2, completion_unix_time: 1_669_959_061, user: aquaj)
      ]
    end

    it "doesn't create duplicates" do
      expect { described_class.call }.to change { aquaj.completions.count }.from(4).to(8)
    end

    it "doesn't re-create them" do
      described_class.call
      # if record doesn't exist, reload raises ActiveRecord::RecordNotFound
      expect { existing_completions.each(&:reload) }.not_to raise_error
    end
  end

  context "when users are split between leaderboards" do
    before do
      allow(Aoc).to receive(:private_leaderboards).and_return(%w[456-a4e66 789-f43b1])
    end

    it "calls AOC for both leaderboards" do
      described_class.call
      expect(WebMock).to have_requested(:get, %r{adventofcode.com.*/456.json})
      expect(WebMock).to have_requested(:get, %r{adventofcode.com.*/789.json})
    end

    it "still fetches all the Completions" do
      expect { described_class.call }
        .to change { aquaj.completions.count }.from(0).to(8)
        .and change { denis.completions.count }.from(0).to(6)
    end
  end

  context "when we have no user for a participant of the leaderboard" do
    let!(:denis) { nil }

    it "doesn't fetch their Completions" do
      expect { described_class.call }
        .to change { Completion.count }.from(0).to(8)
    end
  end

  context "when the process fails halfway through" do
    before do
      allow_any_instance_of(Net::HTTP).to receive(:request).and_raise
    end

    it "doesn't modify the DB" do
      # The most stupid syntax ever used for a spec - thanks Rubocop, original:
      # expect { described_class.call rescue nil }.not_to change { State.count }
      expect do
        described_class.call
      rescue StandardError
        nil
      end.not_to(change { State.count })
    end
  end
end
