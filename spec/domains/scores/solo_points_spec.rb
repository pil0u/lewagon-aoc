# frozen_string_literal: true

require "rails_helper"

RSpec.describe Scores::SoloPoints do
  let!(:state) { create(:state) }
  let!(:user_1) { create(:user, id: 1) }
  let!(:user_2) { create(:user, id: 2) }

  let!(:completions) do
    [
      create_completion(1, 1, user_1, 3.hours + 25.minutes),
      create_completion(1, 2, user_1, 1.day + 12.minutes),
      create_completion(1, 1, user_2, 3.days + 1.minute),
    ]
  end

  def create_completion(day, challenge, user, duration)
    completion_timestamp = DateTime.new(2022, 12, 0 + day, 6, 0, 0) + duration
    create(:completion,
      day:,
      challenge:,
      user:,
      completion_unix_time: completion_timestamp.to_i,
    )
  end

  it "computes the points for users for each challenge" do
    expect(described_class.get).to contain_exactly(
      { score: 50, user_id: 1, day: 1, challenge: 1 },
      { score: 49, user_id: 1, day: 1, challenge: 2 },
      { score: 25, user_id: 2, day: 1, challenge: 1 },
    )
  end

  describe "scoring" do
    let!(:completions) { [] }

    it "gives a user 50 points for a <24hr completion" do
      create_completion(1, 1, user_1, 1.hour + 15.minutes)

      expect(described_class.get).to contain_exactly(
        { score: 50, user_id: 1, day: 1, challenge: 1 },
      )
    end

    it "gives a user 1 less points for a each hour after 24hr" do
      create_completion(1, 1, user_1, 1.day + 6.hours + 4.seconds)

      expect(described_class.get).to contain_exactly(
        { score: 43, user_id: 1, day: 1, challenge: 1 },
      )
    end

    it "gives a user 25 points for >48hr completion" do
      create_completion(1, 1, user_1, 7.days)

      expect(described_class.get).to contain_exactly(
        { score: 25, user_id: 1, day: 1, challenge: 1 },
      )
    end
  end

  describe "caching" do
    it "creates cache records on first call" do
      expect { described_class.get }.to change(Cache::SoloPoint, :count).from(0).to(3)
    end

    context "on second call" do
      before do
        described_class.get
      end

      it "doesn't re-create cache" do
        expect { described_class.get }.not_to change(Cache::SoloPoint, :count)
      end

      it "doesn't do any computation" do
        expect_any_instance_of(described_class).not_to receive(:compute)
        described_class.get
      end
    end
  end
end
