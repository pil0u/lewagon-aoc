# frozen_string_literal: true

FactoryBot.define do
  factory :completion do
    day { rand(1..25) }
    challenge { rand(1..2) }
    association :user
  end
end
