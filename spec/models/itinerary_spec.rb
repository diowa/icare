# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Itinerary do
  let(:male_user) { create :user, gender: 'male' }
  let(:female_user) { create :user, gender: 'female' }
  let(:itinerary) { create :itinerary }

  describe 'before_create' do
    it 'caches driver gender' do
      female_user = create :user, gender: 'female'
      itinerary = create :itinerary, user: female_user
      expect(itinerary.driver_gender).to eq 'female'
    end
  end

  describe '#return_date_validator' do
    let(:invalid_itinerary) { build :itinerary, leave_date: Time.current + 1.day, return_date: Time.current - 1.day, round_trip: true }

    it "adds an error on the return_date field if it's before leave_date" do
      expect(invalid_itinerary.valid?).to be false
      expect(invalid_itinerary.errors.size).to be 1
      expect(invalid_itinerary.errors.messages).to have_key :return_date
    end

    it "adds an error on the return_date field if it's blank" do
      nil_return_date_itinerary = build :itinerary, leave_date: Time.current + 1.day, return_date: nil, round_trip: true
      expect(nil_return_date_itinerary.valid?).to be false
      expect(nil_return_date_itinerary.errors.size).to be 1
      expect(nil_return_date_itinerary.errors.messages).to have_key :return_date
    end
  end

  describe '#driver_is_female' do
    let(:invalid_pink_itinerary) { build :itinerary, user: male_user, pink: true }
    let(:valid_pink_itinerary) { build :itinerary, user: female_user, pink: true }

    it 'adds an error on the pink field if the user is male' do
      expect(invalid_pink_itinerary.valid?).to be false
      expect(invalid_pink_itinerary.errors.size).to be 1
      expect(invalid_pink_itinerary.errors.messages).to have_key :pink
    end

    it 'does not add errors if the user is female' do
      expect(valid_pink_itinerary.valid?).to be true
    end
  end

  describe '#to_s' do
    it "returns itinerary's title" do
      expect(itinerary.to_s).to eq itinerary.title
    end
  end

  describe GeoItinerary do
    let(:route_param) do
      { start_location:    itinerary.start_location.coordinates,
        end_location:      itinerary.end_location.coordinates,
        via_waypoints:     itinerary.via_waypoints,
        overview_path:     itinerary.overview_path,
        overview_polyline: itinerary.overview_polyline }.to_json.to_s
    end

    it 'does not fail if route json object is empty or malformed' do
      invalid_itineraries = [build(:itinerary, start_location: nil, end_location: nil, route: nil),
                             build(:itinerary, start_location: nil, end_location: nil, route: {}),
                             build(:itinerary, start_location: nil, end_location: nil, route: { bad: 'guy' }),
                             build(:itinerary, start_location: nil, end_location: nil, route: { start_location: 'bad' })]
      invalid_itineraries.each do |invalid_itinerary|
        expect(invalid_itinerary.valid?).to be false
        expect(invalid_itinerary.errors.messages).to have_key :start_location
        expect(invalid_itinerary.errors.messages).to have_key :end_location
      end
    end

    it 'builds itinerary from route json object' do
      built_itinerary = build(:itinerary, route: route_param)
      expect(built_itinerary.start_location).to eq itinerary.start_location
      expect(built_itinerary.end_location).to eq itinerary.end_location
      expect(built_itinerary.overview_path).to eq itinerary.overview_path
      expect(built_itinerary.overview_polyline).to eq itinerary.overview_polyline
    end

    describe '#inside_bounds' do
      # Default bounds for testing environment:
      # set :bounds, [
      #   [5, 4],
      #   [7, 4],
      #   [2, 7],
      #   [2, 5]
      # ]

      before do
        APP_CONFIG.itineraries.set :geo_restricted, true
      end

      after do
        APP_CONFIG.itineraries.set :geo_restricted, false
      end

      let(:start_end_outside_bounds_itinerary) do
        build :itinerary,
              start_location: [6, 1],
              end_location:   [9, 5]
      end
      let(:start_outside_bounds_itinerary) do
        build :itinerary,
              start_location: [6, 1],
              end_location:   [3, 6]
      end
      let(:end_outside_bounds_itinerary) do
        build :itinerary,
              start_location: [6, 6],
              end_location:   [3, 9]
      end
      let(:inside_bounds_itinerary) do
        build :itinerary,
              start_location: [2, 6],
              end_location:   [2, 5]
      end

      it 'adds an error on the base objects if both start_position and end_position are outside bounds' do
        expect(start_end_outside_bounds_itinerary.valid?).to be false
        expect(start_end_outside_bounds_itinerary.errors.size).to be 1
        expect(start_end_outside_bounds_itinerary.errors.messages).to have_key :base
      end

      it 'adds an error on the base objects if start_position is outside bounds' do
        expect(start_outside_bounds_itinerary.valid?).to be false
        expect(start_outside_bounds_itinerary.errors.size).to be 1
        expect(start_outside_bounds_itinerary.errors.messages).to have_key :base
      end

      it 'adds an error on the base objects if end_position is outside bounds' do
        expect(end_outside_bounds_itinerary.valid?).to be false
        expect(end_outside_bounds_itinerary.errors.size).to be 1
        expect(end_outside_bounds_itinerary.errors.messages).to have_key :base
      end

      it 'does not add errors if the itinerary is inside bounds' do
        expect(inside_bounds_itinerary.valid?).to be true
      end
    end

    describe '#static_map' do
      it "returns a url of the itinerary's static map" do
        old_google_maps_api_key = APP_CONFIG.google_maps_api_key
        APP_CONFIG.set :google_maps_api_key, 'API_KEY'

        expect(itinerary.static_map).to eq Addressable::URI.encode("https://maps.googleapis.com/maps/api/staticmap?size=640x360&scale=2&markers=color:green|label:B|#{itinerary.end_location.coordinates.reverse.join(',')}&markers=color:green|label:A|#{itinerary.start_location.coordinates.reverse.join(',')}&path=enc:#{itinerary.overview_polyline}&key=API_KEY")
      ensure
        APP_CONFIG.set :google_maps_api_key, old_google_maps_api_key
      end
    end
  end
end
