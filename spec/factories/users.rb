# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    ENV["AOC_ROOMS"] = "1234567-890abc,"

    username { "pil0u" }
    synced { true }
    uid { id }
  end
end
