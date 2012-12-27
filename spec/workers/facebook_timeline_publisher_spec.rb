require 'spec_helper'

describe FacebookTimelinePublisher do
  describe '.perform' do
    # Generic itinerary
    let(:user) { FactoryGirl.create :user, oauth_token: 'test', facebook_permissions: { "publish_stream" => 1 } }
    let(:itinerary) { FactoryGirl.create :itinerary, user: user }

    it "publishes itinerary on facebook timeline" do
      stub_http_request(:post, /graph.facebook.com\/me/).to_return body: 123
      expect(FacebookTimelinePublisher.perform itinerary.id).to_not be_nil
    end

    it "does not fail to publish itinerary if user has no publish stream permission" do
      user.facebook_permissions = {}
      expect(FacebookTimelinePublisher.perform itinerary.id).to be_nil
    end
  end
end
