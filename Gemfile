# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
gem "devise", "~> 4.8"
gem "humanize", "~> 2.5"
gem "importmap-rails", "~> 1.0"
gem "jbuilder", "~> 2.11"
gem "omniauth-kitt", "~> 0.1.0"
gem "omniauth-rails_csrf_protection", "~> 1.0.0"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "rails", "~> 7.0.3"
gem "scenic", "~> 1.6"
gem "sprockets-rails", "~> 3.0"
gem "stimulus-rails", "~> 1.0"
gem "tailwindcss-rails", "~> 2.0"
gem "turbo-rails", "~> 1.0"

group :development, :test do
  gem "brakeman", "~> 5.1.1"
  gem "bundler-audit", "~> 0.9.0"
  gem "erb_lint", "~> 0.1.1", require: false
  gem "rubocop", "~> 1.22", require: false
  gem "rubocop-performance", "~> 1.11", require: false
  gem "rubocop-rails", "~> 2.12", require: false
end

group :development do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "listen", "~> 3.3"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler", "~> 2.0"
end
