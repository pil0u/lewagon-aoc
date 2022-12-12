module Cache
  class Clean
    def self.call(...) = new(...).call

    def initialize(model)
      @cache_model = model
    end

    def call
      created_at_in_local = "(created_at at time zone 'UTC-5')"
      last_of_each_day = @cache_model
        .order(Arel.sql("#{created_at_in_local}::date DESC"), created_at: :desc)
        .select("DISTINCT ON(#{created_at_in_local}::date) cache_fingerprint")

      @cache_model.where.not(cache_fingerprint: last_of_each_day).delete_all
    end
  end
end
