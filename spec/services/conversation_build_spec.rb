require 'spec_helper'

describe ConversationBuild do
  describe 'conversation' do
    # Driver and Passenger users
    let(:driver) { FactoryGirl.create :user }
    let(:passenger) { FactoryGirl.create :user }

    # Generic Itinerary
    let(:itinerary) { FactoryGirl.create :itinerary, user: driver }

    let(:params) { { itinerary_id: itinerary.id, conversation: { message: { sender: passenger, body: 'Test' } } } }

    it "does not fail if params are empty or malformed" do
      invalid_conversation_builds = [ConversationBuild.new({}, passenger),
                                     ConversationBuild.new({ itinerary_id: itinerary.id }, passenger),
                                     ConversationBuild.new({ itinerary_id: itinerary.id, conversation: {} }, passenger),
                                     ConversationBuild.new({ itinerary_id: itinerary.id, conversation: { sender: passenger } }, passenger)]
      invalid_conversation_builds.each do |invalid_conversation_build|
        expect(-> { invalid_conversation_build.conversation }).to_not raise_error Exception
        expect(invalid_conversation_build.conversation.valid?).to be_false if invalid_conversation_build.conversation
      end
    end

    it "builds conversation from params" do
      conversation = ConversationBuild.new(params, passenger).conversation
      conversation.save
      driver.reload
      passenger.reload
      expect(conversation.valid?).to be_true
      expect(conversation.users.include?(driver)).to be_true
      expect(conversation.users.include?(passenger)).to be_true
      expect(driver.conversations.include?(conversation)).to be_true
      expect(passenger.conversations.include?(conversation)).to be_true
    end
  end
end
