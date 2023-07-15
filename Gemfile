# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"
gem "rails", "~> 7.0.5"

gem "blazer", "~> 2.6"
gem "bootsnap", require: false # Reduces boot times through caching; required in config/boot.rb
gem "devise", "~> 4.9"
gem "good_job", "~> 3.15"
gem "humanize", "~> 2.5"
gem "importmap-rails", "~> 1.2"
gem "jbuilder", "~> 2.11"
gem "omniauth-kitt", "~> 0.1"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "pg", "~> 1.5"
gem "puma", "~> 6.3"
gem "rouge", "~> 4.1"
gem "sentry-rails", "~> 5.9"
gem "sentry-ruby", "~> 5.9"
gem "sprockets-rails", "~> 3.4"
gem "stimulus-rails", "~> 1.2"
gem "strong_migrations", "~> 1.4"
gem "tailwindcss-rails", "~> 2.0"
gem "turbo-rails", "~> 1.4"
gem "view_component", "~> 3.2"

group :development, :test do
  gem "brakeman", "~> 6.0"
  gem "bundler-audit", "~> 0.9"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "erb_lint", "~> 0.4", require: false
  gem "factory_bot_rails", "~> 6.2"
  gem "rspec-rails", "~> 6.0"
  gem "rubocop", "~> 1.52", require: false
  gem "rubocop-performance", "~> 1.18", require: false
  gem "rubocop-rails", "~> 2.20", require: false
  gem "rubocop-rspec", "~> 2.22", require: false
  gem "webmock", "~> 3.18"
end

group :development do
  gem "dotenv-rails", "~> 2.8"
  gem "listen", "~> 3.8"

  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler", "~> 2.0"
  gem "solargraph"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", "~> 4.2"
end
