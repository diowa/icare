# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Conversation do
  subject(:conversation) { described_class.new sender: sender, receiver: receiver, conversable: itinerary }

  let(:receiver) { create :user }
  let(:sender) { create :user }
  let(:itinerary) { create :itinerary, user: receiver }

  it 'does not allow conversation between the same user' do
    invalid_conversation = build :conversation, sender: receiver, receiver: receiver
    expect(invalid_conversation.valid?).to be false
    expect(invalid_conversation.errors.messages).to have_key :receiver
  end

  describe '#participants' do
    it 'returns an array with sender and receiver' do
      expect(conversation.participants).to match_array [sender, receiver]
    end
  end

  describe '#participates?' do
    context 'when user participates to conversation as sender' do
      subject { conversation.participates?(sender) }

      it { is_expected.to be true }
    end

    context 'when user participates to conversation as receiver' do
      subject { conversation.participates?(receiver) }

      it { is_expected.to be true }
    end

    context 'when user does not participate to conversation' do
      subject { conversation.participates?(create(:user)) }

      it { is_expected.to be false }
    end
  end

  describe '#last_unread_message' do
    it 'returns the last unread message' do
      conversation.messages << build(:message, sender: sender, body: 'First unread message from sender')
      conversation.save
      expect(conversation.last_unread_message(receiver).body).to eq 'First unread message from sender'
      expect(conversation.last_unread_message(sender)).to be_nil

      conversation.messages << build(:message, sender: sender, body: 'Second unread message from sender')
      conversation.save
      expect(conversation.last_unread_message(receiver).body).to eq 'Second unread message from sender'
      expect(conversation.last_unread_message(sender)).to be_nil

      conversation.messages << build(:message, sender: receiver, body: 'First unread message from receiver')
      conversation.save
      expect(conversation.last_unread_message(sender).body).to eq 'First unread message from receiver'
    end
  end

  describe '#mark_as_read!' do
    it 'marks the conversation as read for provided user' do
      conversation.mark_as_read!(receiver)
      expect(conversation.unread?(receiver)).to be false
    end
  end

  describe '#unread?' do
    before do
      conversation.messages << build(:message, sender: sender, body: 'First unread message from sender')
      conversation.save
    end

    it 'knows if there are unread messages for user' do
      expect(conversation.unread?(receiver)).to be true
      expect(conversation.unread?(sender)).to be false
    end
  end

  describe '#with' do
    subject(:conversation) { described_class.new sender: sender, receiver: receiver }

    it 'returns the other user' do
      expect(conversation.with(receiver)).to eq sender
      expect(conversation.with(sender)).to eq receiver
      expect(conversation.with(nil)).to eq sender
    end
  end
end
