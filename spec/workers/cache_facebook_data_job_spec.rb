require 'spec_helper'

describe CacheFacebookDataJob do
  let(:user) { FactoryGirl.create :user, oauth_token: 'test' }

  before do
    stub_http_request(:post, /graph.facebook.com/).to_return body: [
      { code: 200,
        headers: [{ name: 'Content-Type',
                    value: 'text/javascript; charset=UTF-8' }],
        body: '{}' },
      { code: 200,
        headers: [{ name: 'Content-Type',
                    value: 'text/javascript; charset=UTF-8' }],
        body: '{}' }].to_json
  end

  it 'caches user data when they are nil' do
    expect(CacheFacebookDataJob.perform_now user.id).to be true
  end

  it 'caches user data when they are expired' do
    expect(CacheFacebookDataJob.perform_now user.id).to be true
    expect(CacheFacebookDataJob.perform_now user.id).to be nil
    travel_to APP_CONFIG.facebook.cache_expiry_time.from_now + 1.second do
      expect(CacheFacebookDataJob.perform_now user.id).to be true
      expect(CacheFacebookDataJob.perform_now user.id).to be nil
    end
  end

  it "doesn't cache user data when they are still valid" do
    user_with_fresh_data = FactoryGirl.create :user, oauth_token: 'test', facebook_data_cached_at: Time.current
    expect(CacheFacebookDataJob.perform_now user_with_fresh_data.id).to be nil
  end

  it "doesn't fail when response is wrong" do
    stub_http_request(:post, /graph.facebook.com/).to_return status: 500
    expect(CacheFacebookDataJob.perform_now user.id).to be false
  end
end
