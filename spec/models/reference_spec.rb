# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reference do
  let(:driver) { create :user }
  let(:passenger) { create :user }
  let(:itinerary) { create :itinerary, user: driver }
  let(:reference) { create :reference, user: passenger, itinerary: itinerary }

  context '#not_by_myself' do
    it 'adds an error on user field when a malicious user tries to reference himself' do
      invalid_reference = build :reference, user: driver, itinerary: itinerary
      expect(invalid_reference.valid?).to be false
      expect(invalid_reference.errors.messages).to have_key :user
    end
  end

  context '#unread?' do
    it 'knows if a reference is unread' do
      expect(reference.unread?).to be true
    end
  end

  context '#driver?' do
    it 'knows if the referencing user is the driver' do
      expect(reference.driver?).to be true
    end
  end

  context '#referencing_user' do
    it 'returns the referencing user' do
      expect(reference.referencing_user).to eq driver
    end
  end

  describe References::Outgoing do
    context 'after save' do
      it 'creates a new reference in the driver and set the incoming reference' do
        create :outgoing_reference, reference: reference
        driver.reload
        expect(driver.references).not_to be_empty
        expect(driver.references.first.itinerary).to eq itinerary
        expect(driver.references.first.referencing_user).to eq passenger
        expect(driver.references.first.incoming.rating).to eq reference.outgoing.rating
        expect(driver.references.first.incoming.body).to eq reference.outgoing.body
      end
    end
  end
end
