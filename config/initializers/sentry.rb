# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = "https://eac0ddb72cec4f11bd78df30df76d742@o4504023997087744.ingest.sentry.io/4504023998988288"
  config.breadcrumbs_logger = %i[monotonic_active_support_logger http_logger]

  # Current environments
  #   OK  production        aoc.lewagon.community
  #   OK  staging           aoc-staging.lewagon.community
  config.enabled_environments = %w[production staging]

  config.environment = "staging" if ENV["THIS_IS_STAGING"]

  # Disable traces all the way
  config.traces_sample_rate = 0.0

  # Further use: https://docs.sentry.io/platforms/ruby/guides/rails/configuration/sampling/#setting-a-sampling-function
end
