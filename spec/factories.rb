FactoryGirl.define do

  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :uid do |n|
    "100{n}"
  end

  factory :user do
    email
    uid
    name 'John Doe'
    gender 'male'
    birthday '1980-08-27'
  end
end
