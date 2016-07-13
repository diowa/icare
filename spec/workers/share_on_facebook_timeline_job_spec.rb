# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ShareOnFacebookTimelineJob do
  let(:user) { create :user, access_token: 'test', facebook_permissions: [{ 'permission' => 'publish_actions', 'status' => 'granted' }] }
  let(:itinerary) { create :itinerary, user: user }

  it 'publishes itinerary on facebook timeline' do
    stub_http_request(:post, %r{graph.facebook.com/me}).to_return body: '123'
    expect(ShareOnFacebookTimelineJob.perform_now(itinerary)).to_not be_nil
  end

  it 'does not fail to publish itinerary if user has no publish stream permission' do
    user.facebook_permissions = []
    expect(ShareOnFacebookTimelineJob.perform_now(itinerary)).to be_nil
  end
end
