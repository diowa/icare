require 'spec_helper'

describe ItineraryBuild do
  describe 'itinerary' do
    # Generic itinerary
    let(:itinerary) { FactoryGirl.create :itinerary }

    # Generic male and female users
    let(:male_user) { FactoryGirl.create :user, gender: 'male' }
    let(:female_user) { FactoryGirl.create :user, gender: 'female' }

    let(:params) {
      { route: { start_location: { lat: itinerary.start_location.lat, lng: itinerary.start_location.lng },
                 end_location: { lat: itinerary.end_location.lat, lng: itinerary.end_location.lng },
                 via_waypoints: itinerary.via_waypoints,
                 overview_path: itinerary.overview_path,
                 overview_polyline: itinerary.overview_polyline }.to_json.to_s }
    }

    it "does not fail if route json object is empty or malformed" do
      invalid_itineraries = [ItineraryBuild.new({}, male_user).itinerary,
                             ItineraryBuild.new({ route: { } }, male_user).itinerary,
                             ItineraryBuild.new({ route: { bad: 'guy' } }, male_user).itinerary,
                             ItineraryBuild.new({ route: { start_location: 'bad' } }, male_user).itinerary ]
      invalid_itineraries.each do |invalid_itinerary|
        expect(invalid_itinerary).to_not be_nil
        expect(invalid_itinerary.valid?).to be_false
        expect(invalid_itinerary.errors.messages).to have_key :start_location
        expect(invalid_itinerary.errors.messages).to have_key :end_location
      end
    end

    it "builds itinerary from route json object" do
      built_itinerary = ItineraryBuild.new(params, male_user).itinerary
      expect(built_itinerary.start_location.to_a).to eq itinerary.start_location.to_a
      expect(built_itinerary.end_location.to_a).to eq itinerary.end_location.to_a
      expect(built_itinerary.overview_path).to eq itinerary.overview_path
      expect(built_itinerary.overview_polyline).to eq itinerary.overview_polyline
      expect(built_itinerary.driver_gender).to eq itinerary.user.gender
      expect(built_itinerary.verified).to eq itinerary.user.facebook_verified
    end
  end
end
