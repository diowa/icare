# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sessions' do
  it 'allows users to sign in from Facebook' do
    login_via_facebook

    expect(page).to have_css "a[href=\"#{destroy_user_session_path}\"]"
    expect(User.count).not_to be_zero
  end

  it 'allows users to logout' do
    login_via_facebook

    click_link t('logout')
    expect(page).to have_content t('login_with_facebook')
  end

  it 'redirect to itinerary viewed by guests' do
    itinerary = create :itinerary

    visit itinerary_path(itinerary)

    first("form[action=\"#{user_facebook_omniauth_authorize_path}\"] button").click
    expect(page.title).to eq itinerary.title
    expect(page).to have_content itinerary.user_name
  end

  context 'when authorization succeed' do
    it 'saves some user information from auth hash' do
      user = create :user, uid: '123456'

      login_via_facebook

      user.reload

      expect(user.email).to eq OMNIAUTH_MOCKED_AUTHHASH.info.email
      expect(user.image).to eq OMNIAUTH_MOCKED_AUTHHASH.info.image
      expect(user.name).to eq OMNIAUTH_MOCKED_AUTHHASH.info.name
      expect(user.access_token).to eq OMNIAUTH_MOCKED_AUTHHASH.credentials.token
      expect(user.access_token_expires_at).to eq Time.zone.at(OMNIAUTH_MOCKED_AUTHHASH.credentials.expires_at)
    end
  end

  context 'when authorization fails' do
    it 'redirects to root path' do
      OmniAuth.config.mock_auth[:facebook] = :invalid_credentials
      create :user, uid: '123456', name: 'Duncan MacLeod'

      login_via_facebook

      expect(page).to have_current_path root_path
      expect(page).to have_content t('devise.omniauth_callbacks.failure', kind: 'Facebook', reason: 'Invalid credentials')
    ensure
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH
    end
  end
end
