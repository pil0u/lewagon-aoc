require 'rails_helper'

RSpec.describe Cache::Clean do
  let!(:existing_cache) {
    create :user, id: 1
    create :user, id: 2
    Cache::SoloPoint.insert_all([
      { day: 1, challenge: 1, score: 20, user_id: 1, cache_fingerprint: 'A', created_at: "2022-12-01 13:00:00 UTC" },
      { day: 1, challenge: 1, score: 20, user_id: 2, cache_fingerprint: 'A', created_at: "2022-12-01 13:00:00 UTC" },

      { day: 1, challenge: 1, score: 20, user_id: 1, cache_fingerprint: 'B', created_at: "2022-12-02 04:30:00 UTC" },
      { day: 1, challenge: 1, score: 20, user_id: 2, cache_fingerprint: 'B', created_at: "2022-12-02 04:30:00 UTC" },

      { day: 2, challenge: 1, score: 20, user_id: 1, cache_fingerprint: 'A', created_at: "2022-12-02 13:00:00 UTC" },
      { day: 2, challenge: 1, score: 20, user_id: 2, cache_fingerprint: 'A', created_at: "2022-12-02 13:00:00 UTC" },

      { day: 2, challenge: 1, score: 20, user_id: 1, cache_fingerprint: 'B', created_at: "2022-12-03 04:30:00 UTC" },
      { day: 2, challenge: 1, score: 20, user_id: 2, cache_fingerprint: 'B', created_at: "2022-12-03 04:30:00 UTC" },
    ])
  }

  it "keeps the last set of cache entries for each day" do
    described_class.call(Cache::SoloPoint)
    expect(Cache::SoloPoint.all.map(&:attributes).map(&:symbolize_keys)).to contain_exactly(
      hash_including(day: 1, challenge: 1, score: 20, user_id: 1, cache_fingerprint: 'B'),
      hash_including(day: 1, challenge: 1, score: 20, user_id: 2, cache_fingerprint: 'B'),

      hash_including(day: 2, challenge: 1, score: 20, user_id: 1, cache_fingerprint: 'B'),
      hash_including(day: 2, challenge: 1, score: 20, user_id: 2, cache_fingerprint: 'B'),
    )
  end
end
