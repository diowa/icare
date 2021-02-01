# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorizationService do
  describe '.delete_user' do
    subject { described_class.delete_user user_uid }

    let(:user_uid) { '123456' }

    before do
      stub_request(:post, "https://#{APP_CONFIG.auth0.domain}/oauth/token")
        .to_return(status: 200, body: { access_token: 'ok' }.to_json, headers: {})

      stub_request(:delete, "https://#{APP_CONFIG.auth0.domain}/api/v2/users/#{user_uid}")
        .to_return(status: 200, body: '', headers: {})
    end

    it { is_expected.to eq '' }
  end
end
