# frozen_string_literal: true

if Rails.env.test?
  require "simplecov"
  SimpleCov.start "rails"
end
