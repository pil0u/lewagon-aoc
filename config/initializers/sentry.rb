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
  config.enabled_environments = %w[production heroku-staging fly fly-pr]

  # https://docs.sentry.io/platforms/ruby/guides/rails/configuration/sampling/#setting-a-sampling-function
  config.traces_sampler = lambda do |sampling_context|
    # if this is the continuation of a trace, just use that decision (rate controlled by the caller)
    next sampling_context[:parent_sampled] unless sampling_context[:parent_sampled].nil?

    transaction_context = sampling_context[:transaction_context]
    transaction_name = transaction_context[:name]

    case transaction_name
    when /packs/ # webpack assets from 2021 platform
      0.01
    when "/"
      0.05
    when /InsertNewCompletionsJob/
      0.1
    else
      1.0
    end
  end
end
