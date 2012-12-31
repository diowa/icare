require 'spec_helper'

describe Reference do
  # Driver and Passenger users
  let(:driver) { FactoryGirl.create :user }
  let(:passenger) { FactoryGirl.create :user }

  # Generic Itinerary
  let(:itinerary) { FactoryGirl.create :itinerary, user: driver }

  let(:reference) { FactoryGirl.create :reference, user: passenger, itinerary: itinerary }

  describe '.not_by_myself' do
    it "should add an error on user field when a malicious user tries to reference himself" do
      invalid_reference = FactoryGirl.build :reference, user: driver, itinerary: itinerary
      expect(invalid_reference.valid?).to be_false
      expect(invalid_reference.errors.messages).to have_key :user
    end
  end

  describe '.unread?' do
    it "should know if a reference is unread" do
      expect(reference.unread?).to be_true
    end
  end

  describe '.driver?' do
    it "should know if the referencing user is the driver" do
      expect(reference.driver?).to be_true
    end
  end

  describe '.referencing_user' do
    it "should return the referencing user" do
      expect(reference.referencing_user).to eq driver
    end
  end

  describe References::Outgoing do
    it "should create a new reference in the driver and set the incoming reference after save" do
      FactoryGirl.build :outgoing_reference, reference: reference
      reference.save
      driver.reload
      expect(driver.references).to_not be_empty
      expect(driver.references.first.itinerary).to eq itinerary
      expect(driver.references.first.referencing_user).to eq passenger
      expect(driver.references.first.incoming.rating).to eq reference.outgoing.rating
      expect(driver.references.first.incoming.body).to eq reference.outgoing.body
    end
  end
end
