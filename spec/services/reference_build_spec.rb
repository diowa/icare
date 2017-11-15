# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReferenceBuild do
  describe '.reference' do
    let(:driver) { create :user }
    let(:passenger) { create :user }
    let(:itinerary) { create :itinerary, user: driver }
    let(:params) { { body: 'Positive', rating: '1' } }

    it 'does not fail if params are empty or malformed' do
      invalid_reference_builds = [described_class.new({}, passenger, itinerary),
                                  described_class.new({ body: 'something' }, passenger, itinerary),
                                  described_class.new({ body: 'something', rating: 4 }, passenger, itinerary),
                                  described_class.new(params, driver, itinerary),
                                  described_class.new({}, driver, itinerary)]
      invalid_reference_builds.each do |invalid_reference_build|
        passenger.reload

        invalid_reference = invalid_reference_build.reference
        expect(invalid_reference).not_to be_nil
        expect(invalid_reference.valid?).to be false
      end
    end

    it 'builds reference starting from itinerary, user and outgoing' do
      reference = described_class.new(params, passenger, itinerary).reference
      expect(reference).not_to be_nil
      expect(reference.valid?).to be true
    end
  end
end
