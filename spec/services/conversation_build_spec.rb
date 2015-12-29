require 'spec_helper'

describe ConversationBuild do
  context '.conversation' do
    let(:driver) { FactoryGirl.create :user }
    let(:passenger) { FactoryGirl.create :user }
    let(:itinerary) { FactoryGirl.create :itinerary, user: driver }
    let(:params) { { message: { sender: passenger, body: 'Test' } } }

    it 'does not fail if params are empty or malformed' do
      invalid_conversation_builds = [ConversationBuild.new({}, passenger, itinerary),
                                     ConversationBuild.new({ itinerary_id: itinerary.id }, passenger, itinerary),
                                     ConversationBuild.new({ itinerary_id: itinerary.id, conversation: {} }, passenger, itinerary),
                                     ConversationBuild.new({ itinerary_id: itinerary.id, conversation: { sender: passenger } }, passenger, itinerary)]
      invalid_conversation_builds.each do |invalid_conversation_build|
        expect(-> { invalid_conversation_build.conversation }).to_not raise_error Exception
        expect(invalid_conversation_build.conversation.valid?).to be false if invalid_conversation_build.conversation
      end
    end

    it 'builds conversation from params' do
      conversation = ConversationBuild.new(params, passenger, itinerary).conversation
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
