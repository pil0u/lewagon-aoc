# frozen_string_literal: true

FactoryBot.define do
  factory :state do
    fetch_api_begin { DateTime.new(2022, 12, 3, 12, 34, 12) }
    fetch_api_end { fetch_api_begin + 2.seconds }
  end
end
