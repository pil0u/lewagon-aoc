# frozen_string_literal: true

FactoryBot.define do
  factory :completion do
    day { (1..25).sample }
    challenge { (1..2).to_a.sample }
    association :user
  end
end
