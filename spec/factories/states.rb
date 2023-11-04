# frozen_string_literal: true

FactoryBot.define do
  factory :state do
    fetch_api_begin { Aoc.begin_time + 2.days + 12.hours + 34.minutes + 12.seconds }
    fetch_api_end { fetch_api_begin + 2.seconds }
    completions_fetched { rand(1..10) }
  end
end
