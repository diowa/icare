# frozen_string_literal: true
require 'spec_helper'

describe ShareOnFacebookTimelineJob do
  let(:user) { create :user, oauth_token: 'test', facebook_permissions: { 'publish_actions' => 1 } }
  let(:itinerary) { create :itinerary, user: user }

  it 'publishes itinerary on facebook timeline' do
    stub_http_request(:post, %r{graph.facebook.com/me}).to_return body: '123'
    expect(ShareOnFacebookTimelineJob.perform_now(itinerary.id)).to_not be_nil
  end

  it 'does not fail to publish itinerary if user has no publish stream permission' do
    user.facebook_permissions = {}
    expect(ShareOnFacebookTimelineJob.perform_now(itinerary.id)).to be_nil
  end
end
