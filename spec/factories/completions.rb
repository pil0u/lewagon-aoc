FactoryBot.define do
  factory :completion do
    day { (1..25).sample }
    challenge { (1..2).sample }
    association :user
  end
end
