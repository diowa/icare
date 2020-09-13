# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Application' do
  it 'protects pages from guest users' do
    visit dashboard_path

    expect(page).to have_content t('devise.failure.unauthenticated')
  end

  it 'redirects banned users to the banned page' do
    create :user, banned: true, uid: '123456'

    login_via_facebook

    expect(page).to have_current_path banned_path
    [itineraries_path, new_itinerary_path].each do |path|
      visit path
      expect(page).to have_current_path banned_path
    end
  end

  it 'adds google maps api key' do
    old_google_maps_api_key = APP_CONFIG.google_maps_api_key
    APP_CONFIG.set :google_maps_api_key, 'API_KEY'

    visit root_path

    expect(page).to have_css('script[src$="&key=API_KEY"]', visible: :hidden)
  ensure
    APP_CONFIG.set :google_maps_api_key, old_google_maps_api_key
  end

  context 'with locale' do
    context 'when user is passing an unknown locale param' do
      it 'fallbacks to en-US' do
        user = create :user, uid: '123456'

        login_via_facebook
        visit itineraries_user_path(user, locale: 'XX-ZZ')

        expect(page).to have_content t('users.itineraries.title', locale: 'en-US')
      end
    end

    context 'when user is passing a compatible locale param' do
      it 'fallbacks to en-US' do
        user = create :user, uid: '123456'

        login_via_facebook
        visit itineraries_user_path(user, locale: 'en-XX')

        expect(page).to have_content t('users.itineraries.title', locale: 'en-US')
      end
    end

    context 'when user is coming from facebook with a compatible locale' do
      it 'fallbacks to en-US ' do
        user = create :user, uid: '123456', locale: 'en-YY'

        login_via_facebook
        visit itineraries_user_path(user)

        expect(page).to have_content t('users.itineraries.title', locale: 'en-US')
      end
    end

    context 'when user is using en-XX locale' do
      it 'fallbacks to en-US' do
        user = create :user, uid: '123456', locale: 'en-GB'

        login_via_facebook
        visit itineraries_user_path(user, locale: 'en')

        expect(page).to have_content t('users.itineraries.title', locale: 'en-US')
      end
    end
  end
end
