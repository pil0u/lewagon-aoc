# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = "https://eac0ddb72cec4f11bd78df30df76d742@o4504023997087744.ingest.sentry.io/4504023998988288"
  config.breadcrumbs_logger = %i[monotonic_active_support_logger http_logger]

  # Current environments
  #   development       default local value
  #   fly               lewagon-aoc.fly.dev
  #   fly-pr            lewagon-aoc-pr.fly.dev
  #   heroku-staging    lewagon-aoc-staging.herokuapp.com
  #   production        aoc.lewagon.community

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
end
