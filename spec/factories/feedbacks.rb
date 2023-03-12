# frozen_string_literal: true

FactoryBot.define do
  factory :feedback do
    user
    message { 'Generic Feedback' }
  end
end
