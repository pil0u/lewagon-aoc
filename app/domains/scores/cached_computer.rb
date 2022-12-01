# frozen_string_literal: true

module Scores
  class CachedComputer
    def self.get
      new.get
    end

    private

    def cache(model)
      cached_results = model.where(cache_fingerprint: cache_key.to_s)

      if cached_results.any?
        attributes = self.class::RETURNED_ATTRIBUTES
        cached_results.pluck(*attributes).map { |r| attributes.zip(r).to_h }
      else
        results = yield
        to_cache = results.map { |attrs| attrs.merge(cache_fingerprint: cache_key.to_s) }
        model.insert_all(to_cache) if to_cache.any?
        results
      end
    end

    def cache_key
      @cache_key ||= [
        State.maximum(:fetch_api_end),
        User.maximum(:updated_at)
      ].join("-")
    end
  end
end
