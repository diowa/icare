# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ItinerarySearch do
  describe '.itineraries' do
    let(:male_user) { create :user, gender: 'male' }
    let(:female_user) { create :user, gender: 'female' }
    let(:search_params) do
      { start_location_lat: 0,
        start_location_lng: 0,
        end_location_lat:   1,
        end_location_lng:   1 }
    end

    it 'returns itineraries nearby' do
      create_list :itinerary, 3, start_location: [0, 0], end_location: [1, 1]
      create_list :itinerary, 2, start_location: [0.001, 0.005], end_location: [1.001, 0.999]
      create_list :itinerary, 4, start_location: [0.3, 0.3], end_location: [1.3, 1.3]
      create_list :itinerary, 7, start_location: [2, 3], end_location: [5, 6]
      itineraries = described_class.new(search_params, male_user).itineraries
      expect(itineraries.count).to be 5
    end

    it 'includes reversed itineraries' do
      create_list :itinerary, 3, start_location: [1, 1], end_location: [0, 0], round_trip: true
      create_list :itinerary, 1, start_location: [0, 0], end_location: [1, 1]
      itineraries = described_class.new(search_params, male_user).itineraries
      expect(itineraries.count).to be 4
    end

    it 'discards expired itineraries' do
      valid_itinerary_one = nil
      valid_itinerary_two = nil

      travel_to '2013-01-01' do
        create :itinerary, start_location: [0, 0], end_location: [1, 1], leave_date: '2013-01-02'
        create :itinerary, start_location: [1, 1], end_location: [0, 0], leave_date: '2013-01-02', return_date: '2013-01-03', round_trip: true

        valid_itinerary_one = create :itinerary, start_location: [0, 0], end_location: [1, 1], leave_date: '2013-01-05'
        valid_itinerary_two = create :itinerary, start_location: [1, 1], end_location: [0, 0], leave_date: '2013-01-02', return_date: '2013-01-05', round_trip: true
      end

      travel_to '2013-01-04' do
        itineraries = described_class.new(search_params, male_user).itineraries
        expect(itineraries.count).to be 2
        expect(itineraries).to include valid_itinerary_one
        expect(itineraries).to include valid_itinerary_two
      end
    end

    it 'hides pink itineraries to male users' do
      create :itinerary, start_location: [0, 0], end_location: [1, 1], pink: true, user: female_user
      itineraries = described_class.new(search_params, male_user).itineraries
      expect(itineraries).to be_empty
      itineraries = described_class.new(search_params, female_user).itineraries
      expect(itineraries.count).to be 1
    end

    it 'manages round trip filter' do
      create :itinerary, start_location: [0, 0], end_location: [1, 1]
      create_list :itinerary, 2, start_location: [0, 0], end_location: [1, 1], round_trip: true
      itineraries = described_class.new(search_params.merge(filter_round_trip: '1'), male_user).itineraries
      expect(itineraries.count).to be 2
    end

    it 'manages pink filter for female users' do
      create :itinerary, start_location: [0, 0], end_location: [1, 1]
      create_list :itinerary, 2, start_location: [0, 0], end_location: [1, 1], pink: true, user: female_user
      itineraries = described_class.new(search_params.merge(filter_pink: '1'), female_user).itineraries
      expect(itineraries.count).to be 2
    end

    it 'overrides the pink filter for male users' do
      create :itinerary, start_location: [0, 0], end_location: [1, 1]
      create_list :itinerary, 2, start_location: [0, 0], end_location: [1, 1], pink: true, user: female_user
      itineraries = described_class.new(search_params.merge(filter_pink: '1'), male_user).itineraries
      expect(itineraries.count).to be 1
    end

    it 'manages smoking filter' do
      create :itinerary, start_location: [0, 0], end_location: [1, 1]
      create_list :itinerary, 2, start_location: [0, 0], end_location: [1, 1], smoking_allowed: true
      smoking_itineraries = described_class.new(search_params.merge(filter_smoking_allowed: 'true'), male_user).itineraries
      no_smoking_itineraries = described_class.new(search_params.merge(filter_smoking_allowed: 'false'), male_user).itineraries
      expect(smoking_itineraries.count).to be 2
      expect(no_smoking_itineraries.count).to be 1
    end

    it 'manages pets filter' do
      create :itinerary, start_location: [0, 0], end_location: [1, 1]
      create_list :itinerary, 2, start_location: [0, 0], end_location: [1, 1], pets_allowed: true
      pets_itineraries = described_class.new(search_params.merge(filter_pets_allowed: 'true'), male_user).itineraries
      no_pets_itineraries = described_class.new(search_params.merge(filter_pets_allowed: 'false'), male_user).itineraries
      expect(pets_itineraries.count).to be 2
      expect(no_pets_itineraries.count).to be 1
    end

    it 'manages gender filter' do
      create_list :itinerary, 2, start_location: [0, 0], end_location: [1, 1], user: male_user
      create_list :itinerary, 3, start_location: [0, 0], end_location: [1, 1], user: female_user
      male_itineraries = described_class.new(search_params.merge(filter_driver_gender: 'male'), male_user).itineraries
      female_itineraries = described_class.new(search_params.merge(filter_driver_gender: 'female'), male_user).itineraries
      all_itineraries = described_class.new(search_params.merge(filter_driver_gender: 'samurai'), male_user).itineraries
      expect(male_itineraries.count).to be 2
      expect(female_itineraries.count).to be 3
      expect(all_itineraries.count).to be 5
    end
  end
end
