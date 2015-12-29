require 'spec_helper'

describe ShareOnFacebookTimelineJob do
  let(:user) { FactoryGirl.create :user, oauth_token: 'test', facebook_permissions: { 'publish_actions' => 1 } }
  let(:itinerary) { FactoryGirl.create :itinerary, user: user }

  it 'publishes itinerary on facebook timeline' do
    stub_http_request(:post, %r{graph.facebook.com/me}).to_return body: '123'
    expect(ShareOnFacebookTimelineJob.perform_now itinerary.id).to_not be_nil
  end

  it 'publishes itinerary on facebook group in restricted mode' do
    APP_CONFIG.facebook.set :restricted_group_id, '10'
    stub_http_request(:post, %r{graph.facebook.com/10}).to_return body: '123456'
    expect(ShareOnFacebookTimelineJob.perform_now itinerary.id).to_not be_nil
    APP_CONFIG.facebook.set :restricted_group_id, nil
  end

  it 'does not fail to publish itinerary if user has no publish stream permission' do
    user.facebook_permissions = {}
    expect(ShareOnFacebookTimelineJob.perform_now itinerary.id).to be_nil
  end
end
