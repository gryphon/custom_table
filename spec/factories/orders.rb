FactoryBot.define do
  factory :order do
    sequence(:code) { |n| "ORDERCODE#{n}" }
    sequence(:name) { |n| "ORDERNAME#{n}" }
    sequence(:details) { |n| "ORDERDETAILS#{n}" }
    active { true }
    priority { 1 }
    ordered_at { Date.parse("2022-01-05") }
  end
end
