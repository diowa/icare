require 'spec_helper'

describe 'Sessions' do
  it 'allow users to sign in from Facebook' do
    visit user_omniauth_authorize_path(provider: :facebook)

    expect(page).to have_css "a[href=\"#{destroy_user_session_path}\"]"
    expect(User.count).to_not be_zero
  end

  it 'allow users without birthday (???) to sign in from Facebook' do
    begin
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH.merge info: { name: 'Duncan MacLeod' }, extra: { raw_info: { birthday: nil } }
      FactoryGirl.create :user, uid: '123456'

      visit user_omniauth_authorize_path(provider: :facebook)

      expect(page).to have_css "a[href=\"#{destroy_user_session_path}\"]"
    ensure
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH
    end
  end

  it 'allow users without locale (???) to sign in from Facebook' do
    begin
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH.merge extra: { raw_info: { locale: nil } }
      FactoryGirl.create :user, uid: '123456'

      visit user_omniauth_authorize_path(provider: :facebook)

      expect(page).to have_css "a[href=\"#{destroy_user_session_path}\"]"
    ensure
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH
    end
  end

  it 'fills user profile with data from facebook' do
    user = FactoryGirl.create :user, uid: '123456'

    visit user_omniauth_authorize_path(provider: :facebook)

    user.reload

    expect(user.oauth_token).to eq OMNIAUTH_MOCKED_AUTHHASH.credentials.token
    expect(user.oauth_expires_at).to eq Time.zone.at OMNIAUTH_MOCKED_AUTHHASH.credentials.expires_at

    expect(user.email).to eq OMNIAUTH_MOCKED_AUTHHASH.info.email
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

  it 'allow users to logout' do
    visit user_omniauth_authorize_path(provider: :facebook)

    expect(page).to have_css "a[href=\"#{destroy_user_session_path}\"]"
    click_link I18n.t('logout')
    expect(page).to have_content I18n.t('login_with_facebook')
  end

  it 'redirect to itinerary viewed by guests' do
    itinerary = FactoryGirl.create :itinerary

    visit itinerary_path(itinerary)

    find('a', text: I18n.t('login_with_facebook')).click
    expect(page.title).to eq itinerary.title
    expect(page).to have_content itinerary.user_name
  end

  context 'when authorization fails' do
    it 'redirects to root path' do
      begin
        OmniAuth.config.mock_auth[:facebook] = :invalid_credentials
        FactoryGirl.create :user, uid: '123456', name: 'Duncan MacLeod'

        visit user_omniauth_authorize_path(provider: :facebook)

        expect(current_path).to eq root_path
        expect(page).to have_content I18n.t('devise.omniauth_callbacks.failure', kind: 'Facebook', reason: 'Invalid credentials')
      ensure
        OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH
      end
    end
  end

  context 'RestrictedMode' do
    before(:all) do
      APP_CONFIG.facebook.set :restricted_group_id, '10'
    end

    after(:all) do
      APP_CONFIG.facebook.set :restricted_group_id, nil
    end

    it 'blocks unauthorized users' do
      groups = [{ 'name' => 'A group', 'version' => 1, 'id' => '1', 'administrator' => true },
                { 'name' => 'Another group', 'version' => 1, 'id' => '2' }]
      stub_http_request(:get, %r{graph.facebook.com/me}).to_return body: groups.to_json

      visit user_omniauth_authorize_path(provider: :facebook)

      expect(User.count).to be_zero
      expect(current_path).to eq root_path
      expect(page).to have_content I18n.t('flash.sessions.error.restricted')
    end

    it 'allows authorized users' do
      groups = [{ 'name' => 'A group', 'version' => 1, 'id' => '1', 'administrator' => true },
                { 'name' => 'ICARE GROUP', 'version' => 1, 'id' => '10' }]
      stub_http_request(:get, %r{graph.facebook.com/me}).to_return body: groups.to_json

      visit user_omniauth_authorize_path(provider: :facebook)

      expect(User.count).to_not be_zero
      expect(page).to have_css "a[href=\"#{destroy_user_session_path}\"]"
    end

    it 'sets admin attribute to group admins' do
      groups = [{ 'name' => 'A group', 'version' => 1, 'id' => '1' },
                { 'name' => 'ICARE GROUP', 'version' => 10, 'id' => '10', 'administrator' => true }]
      stub_http_request(:get, %r{graph.facebook.com/me}).to_return body: groups.to_json

      visit user_omniauth_authorize_path(provider: :facebook)

      visit admin_users_path
      expect(current_path).to eq admin_users_path
    end
  end
end
