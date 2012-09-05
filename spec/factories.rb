FactoryGirl.define do

  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :password do |n|
    "person#{n}"
  end

  factory :user do

=begin
    factory :facebook_user do
      ignore do
        uid ""
      end

      after(:create) do |user, evaluator|
        authentication = FactoryGirl.create(:authentication, user: user)
        authentication[:provider] = :facebook
        authentication[:uid] = evaluator.uid
        authentication.save!
        user.activate!
      end
    end

    after(:create) do |user, evaluator|
      FactoryGirl.create(:court, user: user)
    end
=end
  end
end
