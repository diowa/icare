require 'spec_helper'

describe 'Itineraries' do
  ROUND_TRIP_ICON = 'icon-exchange'
  DAILY_ICON = 'icon-repeat'
  PINK_ICON = 'icon-lock'
  XSS_ALERT = "<script>alert('toasty!);</script>"

  describe 'Registered Users' do
    before(:each) do
      @user = FactoryGirl.create :user, uid: '123456', username: 'maria', gender: 'female'
      visit '/auth/facebook'
    end

    it "sanitize malicious description" do
      malicious_itinerary = FactoryGirl.create :itinerary, user: @user, description: XSS_ALERT
      #pending
    end

    it "allow users to search them", js: true do
      FactoryGirl.create :itinerary, round_trip: true
      FactoryGirl.create :itinerary
      visit itineraries_path
      fill_in 'itineraries_search_from', with: 'Milan'
      fill_in 'itineraries_search_to', with: 'Turin'
      click_button 'itineraries-search'
      expect(page).to have_css('.itinerary-thumbnail', count: 2)
    end

    it "allow users to view their own ones" do
      FactoryGirl.create :itinerary, user: @user
      FactoryGirl.create :itinerary, user: @user, round_trip: true
      FactoryGirl.create :itinerary, user: @user, daily: true
      FactoryGirl.create :itinerary, user: @user, pink: true, daily: true
      visit itineraries_user_path(@user)
      @user.itineraries.each do |itinerary|
        row = find(:xpath, "//a[@href='#{itinerary_path(itinerary)}' and text()='#{itinerary.title}']/../..")
        expect(row).to_not be_nil
        expect(row.find(:xpath, ".//i[contains(@class,'#{ROUND_TRIP_ICON}')]")).to_not be_nil if itinerary.round_trip?
        expect(row.find(:xpath, ".//i[contains(@class,'#{DAILY_ICON}')]")).to_not be_nil if itinerary.daily?
        expect(row.find(:xpath, ".//i[contains(@class,'#{PINK_ICON}')]")).to_not be_nil if itinerary.pink?
      end
    end

    it "allow users to delete their own ones" do
      itinerary = FactoryGirl.create :itinerary, user: @user
      visit itineraries_user_path(@user)
      find(:xpath, "//a[@data-method='delete' and @href='#{itinerary_path(itinerary)}']").click
      expect(page).to have_content I18n.t('flash.itineraries.success.destroy')
      expect(page).to_not have_content itinerary.title
    end

    it "allow users to edit their own ones" do
      itinerary = FactoryGirl.create :itinerary, user: @user, description: 'Old description'
      visit itineraries_user_path(@user)
      find(:xpath, "//a[contains(@href, '#{edit_itinerary_path(itinerary)}')]").click
      fill_in 'itinerary_description', with: 'New Description'
      click_button I18n.t('helpers.submit.update', model: Itinerary.model_name.human)
      expect(page).to have_content I18n.t('flash.itineraries.success.update')
      visit itinerary_path(itinerary)
      expect(page).to have_content 'New Description'
    end

    it "doesn't allow male users to see pink itineraries" do
      female_user = FactoryGirl.create :user, gender: 'female'
      pink_itinerary = FactoryGirl.create :itinerary, user: female_user, description: 'Pink itinerary', pink: true
      visit itinerary_path(pink_itinerary)
      expect(current_path).to eq dashboard_path
      expect(page).to have_content I18n.t('flash.itineraries.error.pink')
    end
  end

  describe 'Guests' do
    it "allow guests to see itineraries" do
      itinerary = FactoryGirl.create :itinerary, description: 'Itinerary for guest users'
      visit itinerary_path(itinerary)
      expect(current_path).to eq itinerary_path(itinerary)
      expect(page).to have_content itinerary.description
    end

    it "doesn't allow guests to see pink itineraries" do
      female_user = FactoryGirl.create :user, gender: 'female'
      pink_itinerary = FactoryGirl.create :itinerary, user: female_user, description: 'Pink itinerary', pink: true
      visit itinerary_path(pink_itinerary)
      expect(current_path).to eq root_path
    end
  end
end
