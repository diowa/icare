require 'spec_helper'

describe Itinerary do
  describe 'factory' do
    let(:itinerary) { FactoryGirl.create :itinerary }

    it "returns a valid object" do
      expect(itinerary.valid?).to be_true
    end
  end
end
