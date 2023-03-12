# frozen_string_literal: true

FactoryBot.define do
  factory :conversation do
    association :conversable, factory: :itinerary
    sender { FactoryBot.build(:user) }
    receiver { conversable.user }
  end
end
