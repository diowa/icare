require 'spec_helper'

describe Conversation do
  let(:driver) { FactoryGirl.create :user }
  let(:passenger) { FactoryGirl.create :user }
  let(:itinerary) { FactoryGirl.create :itinerary, user: driver }
  let(:conversation) { FactoryGirl.create :conversation, users: [driver, passenger], conversable: itinerary }

  context '.unread?' do
    it 'knows if there are unread messages for user' do
      conversation.messages << FactoryGirl.build(:message, sender: passenger, body: 'First unread message from Passenger')
      expect(conversation.unread?(driver)).to be true
      expect(conversation.unread?(passenger)).to be false
    end
  end

  context '.users_except' do
    it 'returns all users except the provided one' do
      expect(conversation.users_except(driver).size).to be 1
      expect(conversation.users_except(driver).first).to be passenger
      expect(conversation.users_except(passenger).size).to be 1
      expect(conversation.users_except(passenger).first).to be driver
      expect(conversation.users_except(nil).size).to be 2
      expect(conversation.users_except(nil).include?(passenger)).to be true
      expect(conversation.users_except(nil).include?(driver)).to be true
    end
  end

  context '.mark_as_read' do
    it 'marks the conversation as read for provided user' do
      conversation.mark_as_read(driver)
      expect(conversation.unread?(driver)).to be false
    end
  end

  context '.last_unread_message' do
    it 'returns the last unread message' do
      conversation.messages << FactoryGirl.build(:message, sender: passenger, body: 'First unread message from Passenger')
      expect(conversation.last_unread_message(driver).body).to eq 'First unread message from Passenger'
      expect(conversation.last_unread_message(passenger)).to be_nil
      conversation.messages << FactoryGirl.build(:message, sender: passenger, body: 'Second unread message from Passenger')
      expect(conversation.last_unread_message(driver).body).to eq 'Second unread message from Passenger'
      conversation.messages << FactoryGirl.build(:message, sender: driver, body: 'First unread message from Driver')
      expect(conversation.last_unread_message(passenger).body).to eq 'First unread message from Driver'
    end
  end

  describe Message do
    context '.unread?' do
      it 'knows when message is unread' do
        message = FactoryGirl.build(:message, sender: passenger, body: 'First unread message from Passenger')
        conversation.messages << message
        expect(message.unread?).to be true
      end
    end
  end
end
