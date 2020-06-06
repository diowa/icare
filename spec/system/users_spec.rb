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

    login_via_facebook

    click_link t('delete_account')

    expect(page).to have_current_path root_path
    expect(User.count).to be 0
    expect(page).to have_content t('flash.users.success.destroy')
  end

  describe 'Settings' do
    it 'allows to edit profile' do
      user = create :user, uid: '123456'
      login_via_facebook
      visit settings_path
      fill_in 'user_vehicle_avg_consumption', with: '0.29'
      click_button t('helpers.submit.update', model: User)
      expect(user.reload.vehicle_avg_consumption).to eq 0.29
      expect(find('#user_vehicle_avg_consumption').value).to eq '0.29'
    end

    it 'recovers from errors' do
      create :user, uid: '123456'
      login_via_facebook
      visit settings_path
      fill_in 'user_vehicle_avg_consumption', with: nil
      click_button t('helpers.submit.update', model: User)
      expect(page).to have_css '.alert.alert-danger'
    end
  end

  describe 'Dashboard' do
    it 'shows latest itineraries' do
      female_user = create :user, gender: 'female'
      create :itinerary, pink: true, user: female_user
      create_list :itinerary, 5
      create :user, uid: '123456'

      login_via_facebook

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

          login_via_facebook

          expect(page).to have_css('.table-itinerary tbody tr', count: 6)
        end
      end

      context 'when user is not female' do
        it 'hides them' do
          create :user, uid: '123456', gender: 'male'

          login_via_facebook

          expect(page).to have_css('.table-itinerary tbody tr', count: 5)
        end
      end
    end
  end

  describe 'Profile' do
    let!(:user) do
      create :user, uid:                '123456',
                    facebook_favorites: [{ 'id' => '1900100', 'name' => 'Not a common like' }, { 'id' => '1900102', 'name' => 'Common like' }],
                    languages:          [{ 'id' => '106059522759137', 'name' => 'English' }, { 'id' => '113153272032690', 'name' => 'Italian' }],
                    facebook_verified:  true
    end

    before do
      login_via_facebook
      visit user_path(user)
    end

    it 'highlights common languages' do
      user_with_common_languages = create :user, languages: [{ id: '106059522759137', name: 'English' }]
      visit user_path(user_with_common_languages)
      expect(page).to have_xpath "//div[@class='tag tag-common' and text()='#{t('users.show.language', language: 'English')}']"
    end

    it 'highlights common likes' do
      user_with_mutual_friends = create :user,
                                        facebook_favorites: [{ 'id' => '1910100', 'name' => 'Not a common like' }, { 'id' => '1900102', 'name' => 'Common like' }]
      visit user_path(user_with_mutual_friends)
      expect(page).to have_xpath "//div[@class='tag tag-common tag-sm' and text()='Common like']"
      expect(page).not_to have_xpath "//div[@class='tag tag-common tag-sm' and text()='Not a common like']"
    end

    context 'when user is verified' do
      it 'adds the verified box' do
        expect(page).to have_css '.facebook-verified'
      end
    end
  end
end
