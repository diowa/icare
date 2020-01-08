# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConversationBuild do
  let(:sender) { create :user }
  let(:receiver) { create :user }
  let(:conversable) { create :itinerary, user: sender }
  let(:params) { { message: { body: 'Test' } } }

  describe '#conversation' do
    it 'does not fail if params are empty or malformed' do
      invalid_conversation_builds = [described_class.new(sender, receiver, conversable, {}),
                                     described_class.new(sender, receiver, conversable, conversable_id: conversable.id),
                                     described_class.new(sender, receiver, conversable, conversable_id: conversable.id, conversation: {}),
                                     described_class.new(sender, receiver, conversable, conversable_id: conversable.id, conversation: { sender: sender })]
      invalid_conversation_builds.each do |invalid_conversation_build|
        expect { invalid_conversation_build.conversation }.not_to raise_error
        expect(invalid_conversation_build.conversation.valid?).to be false if invalid_conversation_build.conversation
      end
    end

    it 'builds conversation from params' do
      conversation = described_class.new(sender, receiver, conversable, params).conversation
      conversation.save
      sender.reload
      receiver.reload
      expect(conversation.valid?).to be true
      expect(conversation.participants).to match_array [sender, receiver]
      expect(sender.conversations).to include(conversation)
      expect(receiver.conversations).to include(conversation)
    end
  end

  describe '#message' do
    it 'adds sender to params' do
      message = described_class.new(sender, receiver, conversable, params).message

      expect(message).to eq(body: 'Test', sender: sender)
    end
  end
end
