# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.5"
gem "rails", "~> 7.1.3.4"

gem "blazer", "~> 3.0.4"
gem "bootsnap", require: false # Reduces boot times through caching; required in config/boot.rb
gem "commonmarker", "~> 0.23.10", "< 1"
gem "devise", "~> 4.9.4"
gem "good_job", "~> 3.29.3"
gem "humanize", "~> 3.1.0"
gem "importmap-rails", "~> 2.0.1"
gem "jbuilder", "~> 2.12.0"
gem "omniauth-kitt", "~> 0.1.0"
gem "omniauth-rails_csrf_protection", "~> 1.0.2"
gem "omniauth-slack-openid", "~> 1.2.0"
gem "pg", "~> 1.5.8"
gem "puma", "~> 6.4.2"
gem "rouge", "~> 4.2.1"
gem "sentry-rails", "~> 5.17.3"
gem "sentry-ruby", "~> 5.17.3"
gem "slack-ruby-client", "~> 2.3.0"
gem "sprockets-rails", "~> 3.5.1"
gem "stimulus-rails", "~> 1.3.3"
gem "strong_migrations", "~> 1.8.0"
gem "tailwindcss-rails", "~> 2.6.1"
gem "turbo-rails", "~> 2.0.9"
gem "view_component", "~> 3.12.1"

group :development, :test do
  gem "brakeman", "~> 6.1.2"
  gem "bundler-audit", "~> 0.9.1"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv", "~> 3.1.2"
  gem "erb_lint", "~> 0.5", require: false
  gem "factory_bot_rails", "~> 6.4.3"
  gem "rspec-rails", "~> 6.1.2"
  gem "rubocop", "~> 1.64.1", require: false
  gem "rubocop-performance", "~> 1.21.0", require: false
  gem "rubocop-rails", "~> 2.25.1", require: false
  gem "rubocop-rspec", "~> 2.31.0", require: false
  gem "simplecov", "~> 0.22.0"
  gem "webmock", "~> 3.23.1"
end

group :development do
  gem "listen", "~> 3.9.0"

  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler", "~> 3.3.1"
  gem "solargraph"
  # Access an interactive console on exception pages or by calling "console" anywhere in the code.
  gem "web-console", "~> 4.2.1"
end
