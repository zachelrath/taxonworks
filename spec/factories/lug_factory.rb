FactoryBot.define do
  factory :lug, traits: [:housekeeping] do
    factory :valid_lug do
      text { Faker::Lorem.word }
    end
  end
end
