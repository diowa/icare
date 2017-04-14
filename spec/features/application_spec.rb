# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Application' do
  it 'protects pages from guest users' do
    visit dashboard_path

    expect(page).to have_content I18n.t('devise.failure.unauthenticated')
  end

  it 'redirects banned users to the banned page' do
    create :user, banned: true, uid: '123456'

    visit user_facebook_omniauth_authorize_path

    expect(current_path).to eq banned_path
    [itineraries_path, new_itinerary_path].each do |path|
      visit path
      expect(current_path).to eq banned_path
    end
  end

  context 'Locale' do
    context 'when user is passing an unknown locale param' do
      it 'fallbacks to en-US' do
        user = create :user, uid: '123456'

        visit user_facebook_omniauth_authorize_path
        visit itineraries_user_path(user, locale: 'XX-ZZ')

        expect(page).to have_content I18n.t('users.itineraries.title', locale: 'en-US')
      end
    end

    context 'when user is passing a compatible locale param' do
      it 'fallbacks to en-US' do
        user = create :user, uid: '123456'

        visit user_facebook_omniauth_authorize_path
        visit itineraries_user_path(user, locale: 'en-XX')

        expect(page).to have_content I18n.t('users.itineraries.title', locale: 'en-US')
      end
    end

    context 'when user is coming from facebook with a compatible locale' do
      it 'fallbacks to en-US ' do
        user = create :user, uid: '123456', locale: 'en-YY'

        visit user_facebook_omniauth_authorize_path
        visit itineraries_user_path(user)

        expect(page).to have_content I18n.t('users.itineraries.title', locale: 'en-US')
      end
    end

    context 'when user is using en-XX locale' do
      it 'fallbacks to en-US' do
        user = create :user, uid: '123456', locale: 'en-GB'

        visit user_facebook_omniauth_authorize_path
        visit itineraries_user_path(user, locale: 'en')

        expect(page).to have_content I18n.t('users.itineraries.title', locale: 'en-US')
      end
    end
  end
end
