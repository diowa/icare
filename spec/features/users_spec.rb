# frozen_string_literal: true
require 'spec_helper'

describe 'Users' do
  it 'does not see reports' do
    expect(page).to_not have_css('#navbar-notifications-reports')
  end

  it 'does not see users index' do
    visit admin_users_path

    expect(current_path).to_not eq admin_users_path
  end

  it 'allows to delete account' do
    create :user, uid: '123456', username: 'johndoe'

    visit user_omniauth_authorize_path(provider: :facebook)

    click_link I18n.t('delete_account')
    expect(current_path).to eq root_path
    expect(User.count).to be 0
    expect(User.deleted.count).to be 1
    expect(page).to have_content I18n.t('flash.users.success.destroy')
  end

  context 'Settings' do
    it 'allows to edit profile' do
      user = create :user, uid: '123456', username: 'johndoe'
      visit user_omniauth_authorize_path(provider: :facebook)
      visit settings_path
      fill_in 'user_vehicle_avg_consumption', with: '0.29'
      click_button I18n.t('helpers.submit.update', model: User)
      expect(user.reload.vehicle_avg_consumption).to eq 0.29
      expect(find('#user_vehicle_avg_consumption').value).to eq '0.29'
    end

    it 'recovers from errors' do
      create :user, uid: '123456', username: 'johndoe'
      visit user_omniauth_authorize_path(provider: :facebook)
      visit settings_path
      fill_in 'user_vehicle_avg_consumption', with: nil
      click_button I18n.t('helpers.submit.update', model: User)
      expect(page).to have_css '.alert.alert-danger'
    end
  end

  context 'Dashboard' do
    it 'allows to see latest itineraries' do
      female_user = create :user, gender: 'female'
      create :itinerary, pink: true, user: female_user
      create_list :itinerary, 5
      create :user, uid: '123456', username: 'johndoe'

      visit user_omniauth_authorize_path(provider: :facebook)

      expect(page).to have_css('.table-itinerary tbody tr', count: 5)
    end

    context 'when user is female' do
      it 'includes pink itineraries' do
        begin
          female_user = create :user, gender: 'female'
          create_list :itinerary, 5
          create_list :itinerary, 1, pink: true, user: female_user
          OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH.merge extra: { raw_info: { gender: 'female' } }

          visit user_omniauth_authorize_path(provider: :facebook)

          expect(page).to have_css('.table-itinerary tbody tr', count: 6)
        ensure
          OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH
        end
      end
    end
  end

  context 'Profile' do
    def create_friends_and_refresh(friends)
      @user.update_attribute :facebook_friends, Array.new(friends.to_i) { |i| { 'id' => "90110#{i}", 'name' => "Friend #{i}" } }
      @user.reload

      visit user_path(@user)
    end

    before(:each) do
      @user = create :user, uid: '123456', username: 'johndoe'
      visit user_omniauth_authorize_path(provider: :facebook)
      visit user_path(@user)
    end

    it 'shows the rough number of friends' do
      expect(page).to have_xpath "//div[text()='#{I18n.t('users.show.friends', count: '10-')}']"
      create_friends_and_refresh 6
      expect(page).to have_xpath "//div[text()='#{I18n.t('users.show.friends', count: '10-')}']"
      create_friends_and_refresh 11
      expect(page).to have_xpath "//div[text()='#{I18n.t('users.show.friends', count: '10+')}']"
      create_friends_and_refresh 101
      expect(page).to have_xpath "//div[text()='#{I18n.t('users.show.friends', count: '100+')}']"
      create_friends_and_refresh 1001
      expect(page).to have_xpath "//div[text()='#{I18n.t('users.show.friends', count: '1000+')}']"
      create_friends_and_refresh 5001
      expect(page).to have_xpath "//div[text()='#{I18n.t('users.show.friends', count: '5000')}']"
    end

    it 'shows reference tags' do
      itinerary = create :itinerary, user: @user

      passengers = Array.new(6) { |_| create :user }

      # 1 negative reference
      reference = create :reference, user: passengers.first, itinerary: itinerary
      build :outgoing_reference, reference: reference, rating: -1, body: 'Negative'
      reference.save

      # 2 neutral references
      passengers[1..2].each do |passenger|
        reference = create :reference, user: passenger, itinerary: itinerary
        build :outgoing_reference, reference: reference, rating: 0, body: 'Neutral'
        reference.save
      end

      # 3 negative references
      passengers[3..5].each do |passenger|
        reference = create :reference, user: passenger, itinerary: itinerary
        build :outgoing_reference, reference: reference
        reference.save
      end
      @user.reload
      visit user_path(@user)
      expect(page).to have_content I18n.t('references.snippet.positives', count: @user.references.positives.count)
      expect(page).to have_content I18n.t('references.snippet.neutrals', count: @user.references.neutrals.count)
      expect(page).to have_content I18n.t('references.snippet.negatives', count: @user.references.negatives.count)
    end

    it 'highlights common languages' do
      user_with_common_languages = create :user, languages: [{ id: '106059522759137', name: 'English' }]
      visit user_path(user_with_common_languages)
      expect(page).to have_xpath "//div[@class='tag tag-common' and text()='#{I18n.t('users.show.language', language: 'English')}']"
    end

    it 'highlights common jobs' do
      user_with_common_works = create :user, work: [{ employer: { id: '100', name: 'First Inc.' }, start_date: '0000-00' }]
      visit user_path(user_with_common_works)
      expect(page).to have_xpath "//div[@class='tag tag-common' and text()='First Inc.']"
    end

    it 'highlights common schools' do
      user_with_common_education = create :user, education: [{ school: { id: '300', name: 'A College' }, type: 'College' }]
      visit user_path(user_with_common_education)
      expect(page).to have_xpath "//div[@class='tag tag-common' and text()='A College']"
    end

    it 'does not fail with detailed education' do
      user_with_detailed_education = create :user, education: [{ 'school' => { 'id' => '301', 'name' => 'A High School' }, 'type' => 'High School', 'year' => { 'id' => '1', 'name' => '1999' } }, { 'concentration' => [{ 'id' => '400', 'name' => 'A concentration' }], 'school' => { 'id' => '300', 'name' => 'A College' }, 'type' => 'College', 'year' => { 'id' => '2', 'name' => '2003' } }]
      visit user_path(user_with_detailed_education)
      expect(page).to have_xpath "//div[@class='tag tag-common' and text()='A College']"
    end

    it 'shows mutual friends' do
      mutual_friends = Array.new(6) { |i| { 'id' => "90110#{i}", 'name' => "Mutual friend named #{i}" } }
      @user.update_attribute :facebook_friends, [{ 'id' => '900100', 'name' => 'Not a mutual friend' },
                                                 { 'id' => '900101', 'name' => 'Not a mutual friend' }] + mutual_friends
      @user.reload
      user_with_mutual_friends = create :user,
                                        facebook_friends: [{ 'id' => '910100', 'name' => 'Not a mutual friend' }, { 'id' => '910101', 'name' => 'Not a mutual friend' }] + mutual_friends
      visit user_path(user_with_mutual_friends)
      expect(page).to have_xpath "//div[text()[contains(.,'Mutual friend named ')]]", count: 5
      expect(page).to have_content I18n.t('users.show.and_others', count: 1)
      expect(page).to_not have_content 'Not a common friend'
    end

    it 'highlights common likes' do
      @user.update_attribute :facebook_favorites, [{ 'id' => '1900100', 'name' => 'Not a common like' }, { 'id' => '1900102', 'name' => 'Common like' }]
      @user.reload
      @user_with_common_friends = create :user,
                                         facebook_favorites: [{ 'id' => '1910100', 'name' => 'Not a common like' }, { 'id' => '1900102', 'name' => 'Common like' }]
      visit user_path(@user_with_common_friends)
      expect(page).to have_xpath "//div[@class='tag tag-common tag-sm' and text()='Common like']"
      expect(page).to_not have_xpath "//div[@class='tag tag-common tag-sm' and text()='Not a common like']"
    end

    context 'verified' do
      it 'adds the verified box' do
        begin
          old_mocked_authhash = OMNIAUTH_MOCKED_AUTHHASH
          OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH.merge info: { verified: true }

          visit user_omniauth_authorize_path(provider: :facebook)
          visit user_path(@user)

          expect(page).to have_css '.facebook-verified'
        ensure
          OmniAuth.config.mock_auth[:facebook] = old_mocked_authhash
        end
      end
    end
  end
end
