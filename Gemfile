# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"
gem "rails", "7.1.1"

gem "blazer", "~> 3.0"
gem "bootsnap", require: false # Reduces boot times through caching; required in config/boot.rb
gem "commonmarker", ">= 1.0.0.pre11", "< 2"
gem "devise", "~> 4.9"
gem "good_job", "~> 3.21"
gem "humanize", "~> 2.5"
gem "importmap-rails", "~> 1.2"
gem "jbuilder", "~> 2.11"
gem "omniauth-kitt", "~> 0.1"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "omniauth-slack-openid"
gem "pg", "~> 1.5"
gem "puma", "~> 6.4"
gem "sentry-rails", "~> 5.13"
gem "sentry-ruby", "~> 5.13"
gem "slack-ruby-client"
gem "sprockets-rails", "~> 3.4"
gem "stimulus-rails", "~> 1.2"
gem "strong_migrations", "~> 1.6"
gem "tailwindcss-rails", "~> 2.0"
gem "turbo-rails", "~> 1.4"
gem "view_component", "~> 3.7"

group :development, :test do
  gem "brakeman", "~> 6.0"
  gem "bundler-audit", "~> 0.9"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails", "~> 2.8"
  gem "erb_lint", "~> 0.5", require: false
  gem "factory_bot_rails", "~> 6.2"
  gem "rspec-rails", "~> 6.0"
  gem "rubocop", "~> 1.58", require: false
  gem "rubocop-performance", "~> 1.19", require: false
  gem "rubocop-rails", "~> 2.21", require: false
  gem "rubocop-rspec", "~> 2.24", require: false
  gem "simplecov", "~> 0.22.0"
  gem "webmock", "~> 3.19"
end

group :development do
  gem "listen", "~> 3.8"

  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler", "~> 3.1"
  gem "solargraph"
  # Access an interactive console on exception pages or by calling "console" anywhere in the code.
  gem "web-console", "~> 4.2"
end
