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
        return cached_results.pluck(*attributes).map { |r| attributes.zip(r).to_h }
      else
        results = yield
        to_cache = results.map { |attrs| attrs.merge(cache_fingerprint: cache_key.to_s) }
        model.insert_all(to_cache)
        return results
      end
    end
  end
end
