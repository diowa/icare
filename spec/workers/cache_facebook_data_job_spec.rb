# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CacheFacebookDataJob do
  let(:user) { create :user, access_token: 'test' }

  let(:friends_response) do
    [{ 'id' => '901101', 'name' => 'Friend 1' }]
  end

  let(:permissions_response) do
    [{ 'permission' => 'user_birthday', 'status' => 'granted' },
     { 'permission' => 'user_religion_politics', 'status' => 'granted' },
     { 'permission' => 'user_likes', 'status' => 'granted' },
     { 'permission' => 'user_education_history', 'status' => 'granted' },
     { 'permission' => 'user_work_history', 'status' => 'granted' },
     { 'permission' => 'user_about_me', 'status' => 'granted' },
     { 'permission' => 'email', 'status' => 'granted' },
     { 'permission' => 'public_profile', 'status' => 'granted' },
     { 'permission' => 'publish_actions', 'status' => 'granted' }]
  end

  let(:me_response) do
    {
      'bio' => 'My Bio',
      'birthday' => '10/15/1981',
      'education' => [{ 'school' => { 'id' => '300', 'name' => 'A College' }, 'type' => 'College' }],
      'gender' => 'male',
      'languages' => [{ 'id' => '106059522759137', 'name' => 'English' }, { 'id' => '113153272032690', 'name' => 'Italian' }],
      'locale' => 'en_US',
      'verified' => true,
      'work' =>
        [{ 'employer' => { 'id' => '100', 'name' => 'First Inc.' }, 'start_date' => '0000-00' },
         { 'employer' => { 'id' => '101', 'name' => 'Second Ltd.' }, 'start_date' => '0000-00' },
         { 'employer' => { 'id' => '101', 'name' => 'Third S.p.A.' }, 'start_date' => '0000-00' }],
      'id' => '123456'
    }
  end

  before do
    stub_request(:get, 'https://graph.facebook.com/me/friends?access_token=test')
      .to_return(status: 200, body: friends_response.to_json, headers: {})

    stub_request(:get, 'https://graph.facebook.com/me/permissions?access_token=test')
      .to_return(status: 200, body: permissions_response.to_json, headers: {})

    stub_request(:post, 'https://graph.facebook.com/')
      .with(body: { 'access_token' => 'test', 'batch' => '[{"method":"get","relative_url":"me/music"},{"method":"get","relative_url":"me/books"},{"method":"get","relative_url":"me/movies"},{"method":"get","relative_url":"me/television"},{"method":"get","relative_url":"me/games"}]' })
      .to_return(status: 200, body: [
        { code: 200, body: [{ 'name' => 'Interest 1', 'id' => '1' }, { 'name' => 'Interest 2', 'id' => '2' }].to_json },
        { code: 200, body: [].to_json },
        { code: 200, body: [].to_json },
        { code: 200, body: [].to_json },
        { code: 200, body: [{ 'name' => 'Interest 3', 'id' => '3' }].to_json }
      ].to_json, headers: {})

    stub_request(:get, 'https://graph.facebook.com/me?access_token=test&fields=bio,birthday,education,gender,languages,locale,verified,work')
      .to_return(status: 200, body: me_response.to_json, headers: {})
  end

  context 'when data is nil' do
    it 'does not fail' do
      expect(CacheFacebookDataJob.perform_now(user)).to be true
    end
  end

  context 'when data is expired' do
    it 'updates user data' do
      expect(CacheFacebookDataJob.perform_now(user)).to be true
      expect(CacheFacebookDataJob.perform_now(user)).to be false

      travel_to APP_CONFIG.facebook.cache_expiry_time.from_now + 1.second do
        expect(CacheFacebookDataJob.perform_now(user)).to be true
        expect(CacheFacebookDataJob.perform_now(user)).to be false
      end
    end
  end

  context 'when data is fresh' do
    it "doesn't cache user data" do
      user_with_fresh_data = create :user, access_token: 'test', facebook_data_cached_at: Time.current
      expect(CacheFacebookDataJob.perform_now(user_with_fresh_data)).to be false
    end
  end

  context 'when Graph API returns with an error' do
    it 'does not fail' do
      stub_http_request(:post, /graph.facebook.com/).to_return status: 500
      expect(CacheFacebookDataJob.perform_now(user)).to be true
    end
  end

  context 'when user has no locale' do
    it 'does not fail' do
      stub_request(:get, 'https://graph.facebook.com/me?access_token=test&fields=bio,birthday,education,gender,languages,locale,verified,work')
        .to_return(status: 200, body: me_response.except('locale').to_json, headers: {})

      CacheFacebookDataJob.perform_now(user)

      user.reload

      expect(user.locale).to be nil
    end
  end

  # The person's birthday. This is a fixed format string, like
  # MM/DD/YYYY. However, people can control who can see the year they
  # were born separately from the month and day so this string can be
  # only the year (YYYY) or the month + day (MM/DD)
  #
  # Ref: https://developers.facebook.com/docs/graph-api/reference/user/
  context "when user's birthday" do
    context 'is nil' do
      it 'does not fail' do
        stub_request(:get, 'https://graph.facebook.com/me?access_token=test&fields=bio,birthday,education,gender,languages,locale,verified,work')
          .to_return(status: 200, body: me_response.except('birthday').to_json, headers: {})

        CacheFacebookDataJob.perform_now(user)

        user.reload

        expect(user.birthday).to be nil
      end
    end

    context 'has YYYY format' do
      it 'does not store it' do
        stub_request(:get, 'https://graph.facebook.com/me?access_token=test&fields=bio,birthday,education,gender,languages,locale,verified,work')
          .to_return(status: 200, body: me_response.merge('birthday' => '1980').to_json, headers: {})

        CacheFacebookDataJob.perform_now(user)

        user.reload

        expect(user.birthday).to be nil
      end
    end

    context 'has MM/DD format' do
      it 'does not store it' do
        stub_request(:get, 'https://graph.facebook.com/me?access_token=test&fields=bio,birthday,education,gender,languages,locale,verified,work')
          .to_return(status: 200, body: me_response.merge('birthday' => '08/25').to_json, headers: {})

        CacheFacebookDataJob.perform_now(user)

        user.reload

        expect(user.birthday).to be nil
      end
    end
  end

  it 'fills user profile with data from facebook' do
    CacheFacebookDataJob.perform_now(user)

    user.reload

    expect(user.facebook_friends).to include('id' => '901101', 'name' => 'Friend 1')
    expect(user.facebook_permissions).to include('permission' => 'user_birthday', 'status' => 'granted')

    expect(user.facebook_favorites).to eq [{ 'name' => 'Interest 1', 'id' => '1' }, { 'name' => 'Interest 2', 'id' => '2' }, { 'name' => 'Interest 3', 'id' => '3' }]

    expect(user.bio).to eq 'My Bio'
    expect(user.birthday.to_date).to eq Date.parse('1981-10-15')
    expect(user.education).to eq [{ 'school' => { 'id' => '300', 'name' => 'A College' }, 'type' => 'College' }]
    expect(user.facebook_verified).to be true
    expect(user.gender).to eq 'male'
    expect(user.languages).to eq [{ 'id' => '106059522759137', 'name' => 'English' }, { 'id' => '113153272032690', 'name' => 'Italian' }]
    expect(user.locale).to eq 'en-US'
    expect(user.work).to eq [{ 'employer' => { 'id' => '100', 'name' => 'First Inc.' }, 'start_date' => '0000-00' },
                             { 'employer' => { 'id' => '101', 'name' => 'Second Ltd.' }, 'start_date' => '0000-00' },
                             { 'employer' => { 'id' => '101', 'name' => 'Third S.p.A.' }, 'start_date' => '0000-00' }]
  end
end
