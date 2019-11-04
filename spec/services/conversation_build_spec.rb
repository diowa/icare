# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConversationBuild do
  describe '.conversation' do
    let(:driver) { create :user }
    let(:passenger) { create :user }
    let(:itinerary) { create :itinerary, user: driver }
    let(:params) { { message: { sender: passenger, body: 'Test' } } }

    it 'does not fail if params are empty or malformed' do
      invalid_conversation_builds = [described_class.new({}, passenger, itinerary),
                                     described_class.new({ itinerary_id: itinerary.id }, passenger, itinerary),
                                     described_class.new({ itinerary_id: itinerary.id, conversation: {} }, passenger, itinerary),
                                     described_class.new({ itinerary_id: itinerary.id, conversation: { sender: passenger } }, passenger, itinerary)]
      invalid_conversation_builds.each do |invalid_conversation_build|
        expect { invalid_conversation_build.conversation }.not_to raise_error Exception
        expect(invalid_conversation_build.conversation.valid?).to be false if invalid_conversation_build.conversation
      end
    end

    it 'builds conversation from params' do
      conversation = described_class.new(params, passenger, itinerary).conversation
      conversation.save
      driver.reload
      passenger.reload
      expect(conversation.valid?).to be true
      expect(conversation.users.include?(driver)).to be true
      expect(conversation.users.include?(passenger)).to be true
      expect(driver.conversations.include?(conversation)).to be true
      expect(passenger.conversations.include?(conversation)).to be true
    end
  end
end
