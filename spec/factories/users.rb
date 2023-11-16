# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { "pil0u" }
    synced { true }
    uid { id }
    city_id { batch&.city_id }
  end
end
