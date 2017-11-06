# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users' do
  it 'does not see reports' do
    expect(page).not_to have_css('#navbar-notifications-reports')
  end

  it 'does not see users index' do
    visit admin_users_path

    expect(page).not_to have_current_path admin_users_path
  end

  it 'allows to delete account' do
    create :user, uid: '123456'

    visit user_facebook_omniauth_authorize_path

    click_link I18n.t('delete_account')
    expect(page).to have_current_path root_path
    expect(User.count).to be 0
    expect(User.deleted.count).to be 1
    expect(page).to have_content I18n.t('flash.users.success.destroy')
  end

  context 'Settings' do
    it 'allows to edit profile' do
      user = create :user, uid: '123456'
      visit user_facebook_omniauth_authorize_path
      visit settings_path
      fill_in 'user_vehicle_avg_consumption', with: '0.29'
      click_button I18n.t('helpers.submit.update', model: User)
      expect(user.reload.vehicle_avg_consumption).to eq 0.29
      expect(find('#user_vehicle_avg_consumption').value).to eq '0.29'
    end

    it 'recovers from errors' do
      create :user, uid: '123456'
      visit user_facebook_omniauth_authorize_path
      visit settings_path
      fill_in 'user_vehicle_avg_consumption', with: nil
      click_button I18n.t('helpers.submit.update', model: User)
      expect(page).to have_css '.alert.alert-danger'
    end
  end

  context 'Dashboard' do
    it 'shows latest itineraries' do
      female_user = create :user, gender: 'female'
      create :itinerary, pink: true, user: female_user
      create_list :itinerary, 5
      create :user, uid: '123456'

      visit user_facebook_omniauth_authorize_path

      expect(page).to have_css('.table-itinerary tbody tr', count: 5)
    end

    context 'with pink itineraries' do
      before do
        female_driver = create :user, gender: 'female'
        create_list :itinerary, 5
        create :itinerary, pink: true, user: female_driver
      end

      context 'when user is female' do
        it 'shows them' do
          create :user, uid: '123456', gender: 'female'

          visit user_facebook_omniauth_authorize_path

          expect(page).to have_css('.table-itinerary tbody tr', count: 6)
        end
      end

      context 'when user is not female' do
        it 'hides them' do
          create :user, uid: '123456', gender: 'male'

          visit user_facebook_omniauth_authorize_path

          expect(page).to have_css('.table-itinerary tbody tr', count: 5)
        end
      end
    end
  end

  context 'Profile' do
    let(:user) do
      create :user, uid: '123456',
                    education: [{ 'school' => { 'id' => '300', 'name' => 'A College' }, 'type' => 'College' }],
                    facebook_favorites: [{ 'id' => '1900100', 'name' => 'Not a common like' }, { 'id' => '1900102', 'name' => 'Common like' }],
                    languages: [{ 'id' => '106059522759137', 'name' => 'English' }, { 'id' => '113153272032690', 'name' => 'Italian' }],
                    facebook_verified: true,
                    work: [{ 'employer' => { 'id' => '100', 'name' => 'First Inc.' }, 'start_date' => '0000-00' },
                           { 'employer' => { 'id' => '101', 'name' => 'Second Ltd.' }, 'start_date' => '0000-00' },
                           { 'employer' => { 'id' => '101', 'name' => 'Third S.p.A.' }, 'start_date' => '0000-00' }]
    end

    def create_friends_and_refresh(friends)
      user.update_attribute :facebook_friends, Array.new(friends.to_i) { |i| { 'id' => "90110#{i}", 'name' => "Friend #{i}" } }
      user.reload

      visit user_path(user)
    end

    before do
      user
      visit user_facebook_omniauth_authorize_path
      visit user_path(user)
    end

    it 'shows reference tags' do
      itinerary = create :itinerary, user: user

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
      user.reload
      visit user_path(user)
      expect(page).to have_content I18n.t('references.snippet.positives', count: user.references.positives.count)
      expect(page).to have_content I18n.t('references.snippet.neutrals', count: user.references.neutrals.count)
      expect(page).to have_content I18n.t('references.snippet.negatives', count: user.references.negatives.count)
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

    it 'highlights common likes' do
      user_with_mutual_friends = create :user,
                                        facebook_favorites: [{ 'id' => '1910100', 'name' => 'Not a common like' }, { 'id' => '1900102', 'name' => 'Common like' }]
      visit user_path(user_with_mutual_friends)
      expect(page).to have_xpath "//div[@class='tag tag-common tag-sm' and text()='Common like']"
      expect(page).not_to have_xpath "//div[@class='tag tag-common tag-sm' and text()='Not a common like']"
    end

    context 'verified' do
      it 'adds the verified box' do
        visit user_facebook_omniauth_authorize_path
        visit user_path(user)

        expect(page).to have_css '.facebook-verified'
      end
    end
  end
end
