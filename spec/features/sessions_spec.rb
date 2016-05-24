# frozen_string_literal: true
require 'spec_helper'

describe 'Sessions' do
  it 'allows users to sign in from Facebook' do
    visit user_facebook_omniauth_authorize_path

    expect(page).to have_css "a[href=\"#{destroy_user_session_path}\"]"
    expect(User.count).to_not be_zero
  end

  it 'allows users without birthday (???) to sign in from Facebook' do
    begin
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH.merge info: { name: 'Duncan MacLeod' }, extra: { raw_info: { birthday: nil } }
      create :user, uid: '123456'

      visit user_facebook_omniauth_authorize_path

      expect(page).to have_css "a[href=\"#{destroy_user_session_path}\"]"
    ensure
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH
    end
  end

  it 'allows users without locale (???) to sign in from Facebook' do
    begin
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH.merge extra: { raw_info: { locale: nil } }
      create :user, uid: '123456'

      visit user_facebook_omniauth_authorize_path

      expect(page).to have_css "a[href=\"#{destroy_user_session_path}\"]"
    ensure
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH
    end
  end

  it 'fills user profile with data from facebook' do
    pending 'move to facebook'

    user = create :user, uid: '123456'

    visit user_facebook_omniauth_authorize_path

    user.reload

    expect(user.access_token).to eq OMNIAUTH_MOCKED_AUTHHASH.credentials.token
    expect(user.access_token_expires_at).to eq Time.zone.at(OMNIAUTH_MOCKED_AUTHHASH.credentials.expires_at)

    expect(user.email).to eq OMNIAUTH_MOCKED_AUTHHASH.info.email
    expect(user.image).to eq OMNIAUTH_MOCKED_AUTHHASH.info.image
    expect(user.name).to eq OMNIAUTH_MOCKED_AUTHHASH.info.name

    expect(user.facebook_verified).to be false

    expect(user.username).to eq OMNIAUTH_MOCKED_AUTHHASH.extra.raw_info.username
    expect(user.gender).to eq OMNIAUTH_MOCKED_AUTHHASH.extra.raw_info.gender
    expect(user.bio).to eq OMNIAUTH_MOCKED_AUTHHASH.extra.raw_info.bio
    expect(user.languages).to eq OMNIAUTH_MOCKED_AUTHHASH.extra.raw_info.languages

    expect(user.birthday.to_date).to eq Date.strptime(OMNIAUTH_MOCKED_AUTHHASH.extra.raw_info.birthday, '%m/%d/%Y').at_midnight.to_date
    expect(user.work).to eq OMNIAUTH_MOCKED_AUTHHASH.extra.raw_info.work
    expect(user.education).to eq OMNIAUTH_MOCKED_AUTHHASH.extra.raw_info.education

    expect(user.locale).to eq OMNIAUTH_MOCKED_AUTHHASH.extra.raw_info.locale.tr('_', '-')

    expect(user.username_or_uid).to eq [OMNIAUTH_MOCKED_AUTHHASH.extra.raw_info.username, OMNIAUTH_MOCKED_AUTHHASH.uid]
  end

  it 'allows users to logout' do
    visit user_facebook_omniauth_authorize_path

    expect(page).to have_css "a[href=\"#{destroy_user_session_path}\"]"
    click_link I18n.t('logout')
    expect(page).to have_content I18n.t('login_with_facebook')
  end

  it 'redirect to itinerary viewed by guests' do
    itinerary = create :itinerary

    visit itinerary_path(itinerary)

    find('a', text: I18n.t('login_with_facebook')).click
    expect(page.title).to eq itinerary.title
    expect(page).to have_content itinerary.user_name
  end

  context 'when authorization fails' do
    it 'redirects to root path' do
      begin
        OmniAuth.config.mock_auth[:facebook] = :invalid_credentials
        create :user, uid: '123456', name: 'Duncan MacLeod'

        visit user_facebook_omniauth_authorize_path

        expect(current_path).to eq root_path
        expect(page).to have_content I18n.t('devise.omniauth_callbacks.failure', kind: 'Facebook', reason: 'Invalid credentials')
      ensure
        OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH
      end
    end
  end
end
