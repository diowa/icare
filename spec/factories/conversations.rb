# frozen_string_literal: true

FactoryBot.define do
  factory :conversation do
    conversable factory: %i[itinerary]
    sender { FactoryBot.build(:user) }
    receiver { conversable.user }
  end
end
