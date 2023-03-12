# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    association :sender, factory: :user
    body { 'Hello' }
  end
end
