require 'spec_helper'

describe 'Users' do
  describe 'without admin permissions' do
    before(:each) do
      @user = FactoryGirl.create :user, uid: '123456', username: 'johndoe'
      visit '/auth/facebook'
    end

    it "should not see reports" do
      expect(page).to_not have_css('#navbar-notifications-reports')
    end

    it "should note see users index" do
      visit users_path
      expect(current_path).to eq dashboard_path
    end
  end

  describe 'verified' do
    before(:each) do
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH.merge info: { verified: true }
      @verified_user = FactoryGirl.create :user, uid: '123456', username: 'johndoe'
      visit '/auth/facebook'
    end
    it "should see the verified box" do
      visit user_path(@verified_user)
      expect(find('.facebook-verified')).to be_true
    end
  end

  describe 'Profile' do
    def create_friends_and_refresh(friends)
      @user.update_attribute :facebook_friends, friends.to_i.times.map { |i| { 'id' => "90110#{i}", 'name' => "Friend #{i}" } }
      @user.reload
      visit user_path(@user)
    end

    before(:each) do
      @user = FactoryGirl.create :user, uid: '123456', username: 'johndoe'
      visit '/auth/facebook'
      visit user_path(@user)
    end

    it "should show a rough number of friends" do
      expect(find(:xpath, "//span[text()='#{I18n.t('users.show.friends', count: '10-')}']")).to be_true
      create_friends_and_refresh 6
      expect(find(:xpath, "//span[text()='#{I18n.t('users.show.friends', count: '10-')}']")).to be_true
      create_friends_and_refresh 11
      expect(find(:xpath, "//span[text()='#{I18n.t('users.show.friends', count: '10+')}']")).to be_true
      create_friends_and_refresh 101
      expect(find(:xpath, "//span[text()='#{I18n.t('users.show.friends', count: '100+')}']")).to be_true
      create_friends_and_refresh 1001
      expect(find(:xpath, "//span[text()='#{I18n.t('users.show.friends', count: '1000+')}']")).to be_true
      create_friends_and_refresh 5001
      expect(find(:xpath, "//span[text()='#{I18n.t('users.show.friends', count: '5000')}']")).to be_true
    end

    it "should show reference tags" do
      itinerary = FactoryGirl.create :itinerary, user: @user

      passengers = 6.times.map { |_| FactoryGirl.create :user }

      # 1 negative reference
      reference = FactoryGirl.create :reference, user: passengers.first, itinerary: itinerary
      FactoryGirl.build :outgoing_reference, reference: reference, rating: -1, body: 'Negative'
      reference.save

      # 2 neutral references
      passengers[1..2].each do |passenger|
        reference = FactoryGirl.create :reference, user: passenger, itinerary: itinerary
        FactoryGirl.build :outgoing_reference, reference: reference, rating: 0, body: 'Neutral'
        reference.save
      end

      # 3 negative references
      passengers[3..5].each do |passenger|
        reference = FactoryGirl.create :reference, user: passenger, itinerary: itinerary
        FactoryGirl.build :outgoing_reference, reference: reference
        reference.save
      end
      @user.reload
      visit user_path(@user)
      expect(has_content?(I18n.t('references.snippet.positives', count: @user.references.positives.count))).to be_true
      expect(has_content?(I18n.t('references.snippet.neutrals', count: @user.references.neutrals.count))).to be_true
      expect(has_content?(I18n.t('references.snippet.negatives', count: @user.references.negatives.count))).to be_true
    end

    it "should highlight common languages" do
      user_with_common_languages = FactoryGirl.create :user, languages: [{ id: '106059522759137', name: 'English' }]
      visit user_path(user_with_common_languages)
      expect(find(:xpath, "//span[@class='common' and text()='#{I18n.t('users.show.language', language: 'English')}']")).to be_true
    end

    it "should highlight common jobs" do
      user_with_common_works = FactoryGirl.create :user, work: [ { employer: { id: '100', name: 'First Inc.' }, start_date: '0000-00' } ]
      visit user_path(user_with_common_works)
      expect(find(:xpath, "//span[@class='common' and text()='First Inc.']")).to be_true
    end

    it "should highlight common schools" do
      user_with_common_education = FactoryGirl.create :user, education: [{ school: { id: '300', name: 'A College' }, type: 'College' }]
      visit user_path(user_with_common_education)
      expect(find(:xpath, "//span[@class='common' and text()='A College']")).to be_true
    end

    it "should show mutual friends" do
      mutual_friends = 6.times.map { |i| { 'id' => "90110#{i}", 'name' => "Mutual friend named #{i}" } }
      @user.update_attribute :facebook_friends, [{ 'id' => '900100', 'name' => 'Not a mutual friend' },
                                                 { 'id' => '900101', 'name' => 'Not a mutual friend' }] + mutual_friends
      @user.reload
      user_with_mutual_friends = FactoryGirl.create :user,
                                                    facebook_friends: [{ 'id' => '910100', 'name' => 'Not a mutual friend' }, { 'id' => '910101', 'name' => 'Not a mutual friend' } ] + mutual_friends
      visit user_path(user_with_mutual_friends)
      expect(all(:xpath, "//span[text()[contains(.,'Mutual friend named ')]]").size).to be 5
      expect(has_content?(I18n.t('users.show.and_others', count: 1))).to be_true
      expect(has_content?('Not a common friend')).to be_false
    end

    it "should highlight common likes" do
      @user.update_attribute :facebook_favorites, [ { 'id' => '1900100', 'name' => 'Not a common like' }, { 'id' => '1900102', 'name' => 'Common like' } ]
      @user.reload
      @user_with_common_friends = FactoryGirl.create :user,
                                                     facebook_favorites: [ { 'id' => '1910100', 'name' => 'Not a common like' }, { 'id' => '1900102', 'name' => 'Common like' } ]
      visit user_path(@user_with_common_friends)
      expect(find(:xpath, "//span[@class='common' and text()='Common like']")).to be_true
      expect(-> { find(:xpath, "//span[@class='common' and text()='Not a common like']") }).to raise_error Capybara::ElementNotFound
    end
  end
end
