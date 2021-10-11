# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.4"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false
gem "devise", "~> 4.8"
gem "humanize", "~> 2.5"
gem "jbuilder", "~> 2.7"
gem "omniauth-kitt", "~> 0.1.0"
gem "omniauth-rails_csrf_protection", "~> 1.0.0"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "rails", "~> 6.1.4.1"
gem "sass-rails", ">= 6"
gem "turbolinks", "~> 5"
gem "webpacker", "~> 5.0"

group :development, :test do
  gem "brakeman", "~> 5.1.1"
  gem "bundler-audit", "~> 0.9.0"
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "erb_lint", "~> 0.1.1", require: false
  gem "rubocop", "~> 1.22", require: false
  gem "rubocop-performance", "~> 1.11", require: false
  gem "rubocop-rails", "~> 2.12", require: false
end

group :development do
  gem "dotenv-rails"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "listen", "~> 3.3"
  gem "rack-mini-profiler", "~> 2.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
end
