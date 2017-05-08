# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:user) { create :user }
  let(:male_user) { create :user, gender: 'male' }
  let(:female_user) { create :user, gender: 'female' }
  let(:jack_black) { create :user, name: 'Jack Black' }
  let(:anonymous) { create :user, name: nil }

  context '#age' do
    let(:born_on_1960_10_30) { create :user, birthday: '1960-10-30' }
    let(:born_on_1972_02_29) { create :user, birthday: '1972-02-29' }
    let(:unknown_birthday) { create :user, birthday: nil }

    it "returns user's age" do
      travel_to '2011-02-28 12:00' do
        expect(born_on_1972_02_29.age).to be 38
      end

      travel_to '2011-03-01 12:00' do
        expect(born_on_1972_02_29.age).to be 39
      end

      travel_to '2012-02-28 12:00' do
        expect(born_on_1972_02_29.age).to be 39
      end

      travel_to '2012-02-29 12:00' do
        expect(born_on_1972_02_29.age).to be 40
      end

      travel_to '2012-10-29 12:00' do
        expect(born_on_1960_10_30.age).to be 51
      end

      travel_to '2012-10-30 12:00' do
        expect(born_on_1960_10_30.age).to be 52
      end
    end

    it 'does not raise exceptions if user has no birthday' do
      expect(unknown_birthday.age).to be_nil
    end
  end

  context '#female?' do
    it 'answers true if user is female' do
      expect(female_user.female?).to be true
    end

    it 'answers false if user is male' do
      expect(male_user.female?).to be false
    end
  end

  context '#first_name' do
    it "returns user's first name" do
      expect(jack_black.first_name).to eq 'Jack'
    end

    it 'does not raise exceptions if user has no name' do
      expect(anonymous.first_name).to be_nil
    end
  end

  context '#to_s' do
    it "returns user's name when available" do
      expect(jack_black.to_s).to eq 'Jack Black'
      expect(anonymous.to_s).to eq anonymous.id.to_s
    end
  end

  context '#unread_conversations_count' do
    it 'returns the number of unread conversations' do
      driver = create :user
      passenger = create :user
      itinerary = create :itinerary, user: driver
      conversation = create :conversation, users: [driver, passenger], conversable: itinerary
      conversation.messages << build(:message, sender: driver, body: 'First unread message from Driver')

      expect(passenger.unread_conversations_count).to be 1
    end
  end

  context '#unread_references_count' do
    it 'returns the number of unread references' do
      driver = create :user
      passenger = create :user
      itinerary = create :itinerary, user: driver
      reference = build :reference, user: passenger, itinerary: itinerary
      build :outgoing_reference, reference: reference, rating: 1, body: 'Positive'
      reference.save

      expect(passenger.unread_references_count).to be 1
    end
  end
end
