# frozen_string_literal: true

FactoryBot.define do
  factory :snippet do
    association :user
  end
end
