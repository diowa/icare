require 'spec_helper'

describe ItineraryObserver do
  context 'after create' do
    it "asynchronously publishes on facebook timeline if requested by user" do
      expect(-> { FactoryGirl.create :itinerary, share_on_facebook_timeline: true }).to_not raise_error Exception
    end
  end
end
