# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.5"
gem "rails", "~> 7.2.2.1"

gem "active_flag"
gem "blazer"
gem "bootsnap", require: false # Reduces boot times through caching; required in config/boot.rb
gem "commonmarker", "< 1"
gem "devise"
gem "good_job", "~> 3.99.x"
gem "humanize"
gem "importmap-rails"
gem "inline_svg"
gem "jbuilder"
gem "omniauth-kitt"
gem "omniauth-rails_csrf_protection"
gem "omniauth-slack-openid"
gem "pg"
gem "puma"
gem "rouge"
gem "sentry-rails"
gem "sentry-ruby"
gem "slack-ruby-client"
gem "sprockets-rails"
gem "stimulus-rails"
gem "strong_migrations"
gem "tailwindcss-rails"
gem "turbo-rails"
gem "view_component"

group :development, :test do
  gem "brakeman"
  gem "bundler-audit"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv"
  gem "erb_lint", require: false
  gem "factory_bot_rails"
  gem "rspec-rails", "~> 8"
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "simplecov"
  gem "webmock"
end

group :development do
  gem "listen"

  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler"
  # Access an interactive console on exception pages or by calling "console" anywhere in the code.
  gem "web-console"
end
