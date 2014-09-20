require 'spec_helper'

describe FacebookDataCacher do
  context '.perform' do
    let(:user) { FactoryGirl.create :user, oauth_token: 'test' }

    before do
      stub_http_request(:post, /graph.facebook.com/).to_return body: [
          { code: 200,
            headers: [{ name: 'Content-Type',
                        value: 'text/javascript; charset=UTF-8' }],
            body: "{}" },
          { code: 200,
            headers: [{ name: 'Content-Type',
                        value: 'text/javascript; charset=UTF-8' }],
            body: "{}" } ].to_json
    end

    it "caches user data when it is nil" do
      expect(FacebookDataCacher.perform user.id).to be true
    end

    it "caches user data when it is expired" do
      expect(FacebookDataCacher.perform user.id).to be true
      expect(FacebookDataCacher.perform user.id).to be nil
      Delorean.time_travel_to APP_CONFIG.facebook.cache_expiry_time.from_now
      expect(FacebookDataCacher.perform user.id).to be true
      expect(FacebookDataCacher.perform user.id).to be nil
    end

    it "doesn't cache user data when it is still valid" do
      user.facebook_data_cached_at = Time.now
      expect(FacebookDataCacher.perform user.id).to be nil
    end

    it "doesn't fail when response is wrong" do
      stub_http_request(:post, /graph.facebook.com/).to_return code: 500
      expect(FacebookDataCacher.perform user.id).to be nil
    end
  end
end
