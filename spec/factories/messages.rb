# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    sender factory: %i[user]
    body { 'Hello' }
  end
end
