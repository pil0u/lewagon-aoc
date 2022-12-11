module Cache
  class Clean
    def self.call(...) = new(...).call

    def initialize(model)
      @cache_model = model
    end

    def call
      last_of_each_day = @cache_model
        .order("created_at::date DESC", created_at: :desc)
        .select('DISTINCT ON(created_at::date) cache_fingerprint')

      @cache_model.where.not(cache_fingerprint: last_of_each_day).delete_all
    end
  end
end
