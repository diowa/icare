require 'spec_helper'

describe 'Application' do
  it 'protects pages from guest users' do
    visit dashboard_path

    expect(page).to have_content I18n.t('devise.failure.unauthenticated')
  end

  it 'redirects banned users to the banned page' do
    FactoryGirl.create :user, banned: true, uid: '123456'

    visit user_omniauth_authorize_path(provider: :facebook)

    expect(current_path).to eq banned_path
    [itineraries_path, new_itinerary_path].each do |path|
      visit path
      expect(current_path).to eq banned_path
    end
  end

  it 'fallbacks on fbjssdk_channel' do
    visit fbjssdk_channel_path

    expect(page.status_code).to eq 200
  end

  context 'Locale' do
    it 'fallbacks to en-US when user is passing an unknown locale param' do
      user = FactoryGirl.create :user, uid: '123456'

      visit user_omniauth_authorize_path(provider: :facebook)
      visit itineraries_user_path(user, locale: 'XX-ZZ')

      expect(page).to have_content I18n.t('users.itineraries.title', locale: 'en-US')
    end

    it 'fallbacks to en-US when user is passing a compatible locale param' do
      user = FactoryGirl.create :user, uid: '123456'

      visit user_omniauth_authorize_path(provider: :facebook)
      visit itineraries_user_path(user, locale: 'en-XX')

      expect(page).to have_content I18n.t('users.itineraries.title', locale: 'en-US')
    end

    it 'fallbacks to en-US when user is coming from facebook with a compatible locale' do
      user = FactoryGirl.create :user, uid: '123456', locale: 'en-YY'

      visit user_omniauth_authorize_path(provider: :facebook)
      visit itineraries_user_path(user)

      expect(page).to have_content I18n.t('users.itineraries.title', locale: 'en-US')
    end

    it 'fallbacks to en-US when user is using en locale' do
      user = FactoryGirl.create :user, uid: '123456', locale: 'en-GB'

      visit user_omniauth_authorize_path(provider: :facebook)
      visit itineraries_user_path(user, locale: 'en')

      expect(page).to have_content I18n.t('users.itineraries.title', locale: 'en-US')
    end
  end
end
