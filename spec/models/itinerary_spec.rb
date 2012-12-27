require 'spec_helper'

describe Itinerary do
  # Generic itinerary
  let(:itinerary) { FactoryGirl.create :itinerary }

  # Generic male and female users
  let(:male_user) { FactoryGirl.create :user, gender: 'male' }
  let(:female_user) { FactoryGirl.create :user, gender: 'female' }

  describe 'return_date_validator' do
    let(:invalid_itinerary) { FactoryGirl.build :itinerary, leave_date: Time.now + 1.day, return_date: Time.now - 1.day, round_trip: true }

    it "adds an error on the return_date field if it's before leave_date" do
      expect(invalid_itinerary.valid?).to be_false
      expect(invalid_itinerary.errors.size).to be 1
      expect(invalid_itinerary.errors.messages).to have_key :return_date
    end
  end

  describe 'driver_is_female' do
    let(:invalid_pink_itinerary) { FactoryGirl.build :itinerary, user: male_user, pink: true }
    let(:valid_pink_itinerary) { FactoryGirl.build :itinerary, user: female_user, pink: true }

    it "adds an error on the pink field if the user is male" do
      expect(invalid_pink_itinerary.valid?).to be_false
      expect(invalid_pink_itinerary.errors.size).to be 1
      expect(invalid_pink_itinerary.errors.messages).to have_key :pink
    end

    it "does not add errors if the user is female" do
      expect(valid_pink_itinerary.valid?).to be_true
    end
  end

  describe 'inside_bounds' do

    before do
      APP_CONFIG.itineraries.set :geo_restricted, true
      # Default bounds for testing environment:
      # sw: [2, 5]
      # ne: [4, 7]
    end

    after do
      APP_CONFIG.itineraries.set :geo_restricted, false
    end

    let(:start_end_outside_bounds_itinerary) { FactoryGirl.build :itinerary,
                                                                  start_location: { lat: 6, lng: 1},
                                                                  end_location:   { lat: 9, lng: 5 } }
    let(:start_outside_bounds_itinerary)     { FactoryGirl.build :itinerary,
                                                                  start_location: { lat: 6, lng: 1},
                                                                  end_location:   { lat: 3, lng: 6 } }
    let(:end_outside_bounds_itinerary)       { FactoryGirl.build :itinerary,
                                                                  start_location: { lat: 3, lng: 6},
                                                                  end_location:   { lat: -5, lng: 9 } }
    let(:inside_bounds_itinerary)            { FactoryGirl.build :itinerary,
                                                                  start_location: { lat: 2, lng: 6},
                                                                  end_location:   { lat: 2, lng: 5 } }

    it "adds an error on the base objects if both start_position and end_position are outside bounds" do
      expect(start_end_outside_bounds_itinerary.valid?).to be_false
      expect(start_end_outside_bounds_itinerary.errors.size).to be 1
      expect(start_end_outside_bounds_itinerary.errors.messages).to have_key :route
    end

    it "adds an error on the base objects if start_position is outside bounds" do
      expect(start_outside_bounds_itinerary.valid?).to be_false
      expect(start_outside_bounds_itinerary.errors.size).to be 1
      expect(start_outside_bounds_itinerary.errors.messages).to have_key :route
    end

    it "adds an error on the base objects if end_position is outside bounds" do
      expect(end_outside_bounds_itinerary.valid?).to be_false
      expect(end_outside_bounds_itinerary.errors.size).to be 1
      expect(end_outside_bounds_itinerary.errors.messages).to have_key :route
    end

    it "does not add errors if the itinerary is inside bounds" do
      expect(inside_bounds_itinerary.valid?).to be_true
    end
  end

  describe 'to_latlng_array' do
    it "converts Point in latitude, longitude array" do
      latlng_start_location_a = itinerary.start_location.to_latlng_a
      expect(itinerary.start_location.to_latlng_a.class).to be Array
      expect(latlng_start_location_a.size).to be 2
      expect(latlng_start_location_a.first).to be itinerary.start_location.lat
      expect(latlng_start_location_a.last).to be itinerary.start_location.lng
    end
  end

  describe 'to_latlng_hash' do
    it "converts Point in lat: latitude, lng: longitude hash" do
      latlng_start_location_hash = itinerary.start_location.to_latlng_hash
      expect(latlng_start_location_hash.class).to be Hash
      expect(latlng_start_location_hash.size).to be 2
      expect(latlng_start_location_hash).to have_key :lat
      expect(latlng_start_location_hash).to have_key :lng
      expect(latlng_start_location_hash[:lat]).to be itinerary.start_location.lat
      expect(latlng_start_location_hash[:lng]).to be itinerary.start_location.lng
    end
  end

  describe '.static_map' do
    it "returns a url of the itinerary's static map" do
      expect(itinerary.static_map).to eq URI.encode("http://maps.googleapis.com/maps/api/staticmap?size=200x200&scale=2&sensor=false&markers=color:green|label:B|#{itinerary.end_location.to_latlng_a.join(",")}&markers=color:green|label:A|#{itinerary.start_location.to_latlng_a.join(",")}&path=enc:#{itinerary.overview_polyline}")
    end
  end

  describe '.to_s' do
    it "returns itinerary's title" do
      expect(itinerary.to_s).to eq itinerary.title
    end
  end
end
