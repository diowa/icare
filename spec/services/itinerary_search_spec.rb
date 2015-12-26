require 'spec_helper'

describe ItinerarySearch do
  context '.itineraries' do
    let(:male_user) { FactoryGirl.create :user, gender: 'male' }
    let(:female_user) { FactoryGirl.create :user, gender: 'female' }
    let(:search_params) do
      { start_location_lat: 0,
        start_location_lng: 0,
        end_location_lat: 1,
        end_location_lng: 1 }
    end

    it 'rescues on errors' do
      itineraries = ItinerarySearch.new({ start_location_lng: Hash }, male_user).itineraries
      expect(itineraries).to be_empty
    end

    it 'returns itineraries nearby' do
      3.times { FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1] }
      2.times { FactoryGirl.create :itinerary, start_location: [0.001, 0.005], end_location: [1.001, 0.999] }
      4.times { FactoryGirl.create :itinerary, start_location: [0.3, 0.3], end_location: [1.3, 1.3] }
      7.times { FactoryGirl.create :itinerary, start_location: [2, 3], end_location: [5, 6] }
      itineraries = ItinerarySearch.new(search_params, male_user).itineraries
      expect(itineraries.count).to be 5
    end

    it 'includes reversed itineraries' do
      3.times { FactoryGirl.create :itinerary, start_location: [1, 1], end_location: [0, 0], round_trip: true }
      1.times { FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1] }
      itineraries = ItinerarySearch.new(search_params, male_user).itineraries
      expect(itineraries.count).to be 4
    end

    it 'discards expired itineraries' do
      travel_to '2013-01-01' do
        FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1], leave_date: '2013-01-02'
        FactoryGirl.create :itinerary, start_location: [1, 1], end_location: [0, 0], leave_date: '2013-01-02', return_date: '2013-01-03', round_trip: true

        valid_itinerary_1 = FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1], leave_date: '2013-01-05'
        valid_itinerary_2 = FactoryGirl.create :itinerary, start_location: [1, 1], end_location: [0, 0], leave_date: '2013-01-02', return_date: '2013-01-05', round_trip: true

        travel_to '2013-01-04' do
          itineraries = ItinerarySearch.new(search_params, male_user).itineraries
          expect(itineraries.count).to be 2
          expect(itineraries).to include valid_itinerary_1
          expect(itineraries).to include valid_itinerary_2
        end
      end
    end

    it 'hides pink itineraries to male users' do
      FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1], pink: true, user: female_user
      itineraries = ItinerarySearch.new(search_params, male_user).itineraries
      expect(itineraries).to be_empty
      itineraries = ItinerarySearch.new(search_params, female_user).itineraries
      expect(itineraries.count).to be 1
    end

    it 'manages round trip filter' do
      FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1]
      2.times { FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1], round_trip: true }
      itineraries = ItinerarySearch.new(search_params.merge(filter_round_trip: '1'), male_user).itineraries
      expect(itineraries.count).to be 2
    end

    it 'manages pink filter for female users' do
      FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1]
      2.times { FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1], pink: true, user: female_user }
      itineraries = ItinerarySearch.new(search_params.merge(filter_pink: '1'), female_user).itineraries
      expect(itineraries.count).to be 2
    end

    it 'overrides the pink filter for male users' do
      FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1]
      2.times { FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1], pink: true, user: female_user }
      itineraries = ItinerarySearch.new(search_params.merge(filter_pink: '1'), male_user).itineraries
      expect(itineraries.count).to be 1
    end

    it 'manages verified filter' do
      verified_user = FactoryGirl.create :user, facebook_verified: true
      FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1]
      2.times { FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1], user: verified_user }
      itineraries = ItinerarySearch.new(search_params.merge(filter_verified: '1'), female_user).itineraries
      expect(itineraries.count).to be 2
    end

    it 'manages smoking filter' do
      FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1]
      2.times { FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1], smoking_allowed: true }
      smoking_itineraries = ItinerarySearch.new(search_params.merge(filter_smoking_allowed: 'true'), male_user).itineraries
      no_smoking_itineraries = ItinerarySearch.new(search_params.merge(filter_smoking_allowed: 'false'), male_user).itineraries
      expect(smoking_itineraries.count).to be 2
      expect(no_smoking_itineraries.count).to be 1
    end

    it 'manages pets filter' do
      FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1]
      2.times { FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1], pets_allowed: true }
      pets_itineraries = ItinerarySearch.new(search_params.merge(filter_pets_allowed: 'true'), male_user).itineraries
      no_pets_itineraries = ItinerarySearch.new(search_params.merge(filter_pets_allowed: 'false'), male_user).itineraries
      expect(pets_itineraries.count).to be 2
      expect(no_pets_itineraries.count).to be 1
    end

    it 'manages gender filter' do
      2.times { FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1], user: male_user }
      3.times { FactoryGirl.create :itinerary, start_location: [0, 0], end_location: [1, 1], user: female_user }
      male_itineraries = ItinerarySearch.new(search_params.merge(filter_driver_gender: 'male'), male_user).itineraries
      female_itineraries = ItinerarySearch.new(search_params.merge(filter_driver_gender: 'female'), male_user).itineraries
      all_itineraries = ItinerarySearch.new(search_params.merge(filter_driver_gender: 'samurai'), male_user).itineraries
      expect(male_itineraries.count).to be 2
      expect(female_itineraries.count).to be 3
      expect(all_itineraries.count).to be 5
    end
  end
end
