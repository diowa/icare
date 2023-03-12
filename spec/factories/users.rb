# frozen_string_literal: true

FactoryBot.define do
  sequence(:uid)      { |n| "100#{n}" }
  sequence(:email)    { |n| "person#{n}@example.com" }

  factory :user do
    uid
    email
    provider { 'auth0' }
    name { Faker::Name.name }
    gender { 'male' }
    birthday { Faker::Date.birthday(min_age: 18, max_age: 50) }
  end
end
