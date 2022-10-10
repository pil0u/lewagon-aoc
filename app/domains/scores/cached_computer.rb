module Scores
  class CachedComputer
    def self.get
      new.get
    end

    private

    def cache(model)
      cached_results = model.where(cache_key: cache_key)

      if cached_results.any?
        attributes = self.class::RETURNED_ATTRIBUTES
        return cached_results.pluck(*attributes).map { |r| attributes.zip(r).to_h }
      else
        results = yield
        to_cache = results.map { |attributes| attributes.merge(cache_key: cache_key) }
        model.insert_all(to_cache)
        return results
      end
    end
  end
end
