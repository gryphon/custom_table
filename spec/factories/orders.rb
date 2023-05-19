FactoryBot.define do
  factory :order do
    sequence(:code) { |n| "ORDERCODE#{n}" }
    sequence(:name) { |n| "ORDERNAME#{n}" }
    sequence(:details) { |n| "ORDERDETAILS#{n}" }
  end
end
