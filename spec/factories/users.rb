FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "email_#{n}@email.com" }

    password { 'test123456' }
    password_confirmation { 'test123456' }

  end
end
