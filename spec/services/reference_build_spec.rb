require 'spec_helper'

describe ReferenceBuild do
  context '.reference' do
    let(:driver) { FactoryGirl.create :user }
    let(:passenger) { FactoryGirl.create :user }
    let(:itinerary) { FactoryGirl.create :itinerary, user: driver }
    let(:params) { { body: 'Positive', rating: '1' } }

    it 'does not fail if params are empty or malformed' do
      invalid_reference_builds = [ReferenceBuild.new({}, passenger, itinerary),
                                  ReferenceBuild.new({ body: 'something' }, passenger, itinerary),
                                  ReferenceBuild.new({ body: 'something', rating: 4 }, passenger, itinerary),
                                  ReferenceBuild.new(params, driver, itinerary),
                                  ReferenceBuild.new({}, driver, itinerary)]
      invalid_reference_builds.each do |invalid_reference_build|
        passenger.reload

        invalid_reference = invalid_reference_build.reference
        expect(invalid_reference).to_not be_nil
        expect(invalid_reference.valid?).to be false
      end
    end

    it 'builds reference starting from itinerary, user and outgoing' do
      reference = ReferenceBuild.new(params, passenger, itinerary).reference
      expect(reference).to_not be_nil
      expect(reference.valid?).to be true
    end
  end
end
