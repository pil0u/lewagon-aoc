# frozen_string_literal: true

module Scores
  class CachedComputer
    def self.get
      new.get
    end

    private

    # Lifecycle hook
    def after_compute; end

    def cache(model)
      cached_results = model.where(cache_fingerprint: cache_key.to_s)

      if cached_results.any?
        attributes = model.column_names.map(&:to_sym) - [:id, :cache_fingerprint]

        cached_results.pluck(*attributes).map { |r| attributes.zip(r).to_h }
      else
        results = yield
        to_cache = results.map { |attrs| attrs.merge(cache_fingerprint: cache_key.to_s) }
        model.insert_all(to_cache) if to_cache.any?

        after_compute # Hook call

        results
      end
    end
  end
end
