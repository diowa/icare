require 'spec_helper'

describe 'Itineraries' do
  ROUND_TRIP_ICON = 'span.fa.fa-exchange'
  DAILY_ICON = 'span.fa.fa-repeat'
  PINK_ICON = 'span.fa.fa-lock'
  XSS_ALERT = "<script>alert('toasty!);</script>"

  context 'Registered Users' do
    def login_as_male
      @user = FactoryGirl.create :user, uid: '123456', gender: 'male'

      visit user_omniauth_authorize_path(provider: :facebook)
      # NOTE: without the below line, the first test will fail, like it didn't vist the authentication link
      expect(current_path).to eq dashboard_path
    end

    def login_as_female
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH.merge info: { name: 'Johanna Doe' }, extra: { raw_info: { gender: 'female' } }
      @user = FactoryGirl.create :user, uid: '123456', name: 'Johanna Doe', gender: 'female'

      visit user_omniauth_authorize_path(provider: :facebook)
      # NOTE: without the below line, the first test will fail, like it didn't vist the authentication link
      expect(current_path).to eq dashboard_path
    ensure
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH
    end

    it 'are allowed to create itineraries', js: true do
      login_as_female

      visit new_itinerary_path

      fill_in 'itinerary_start_address', with: 'Milan'
      fill_in 'itinerary_end_address', with: 'Turin'
      click_button 'get-route'
      click_button 'wizard-next-step-button'

      leave_date = Time.zone.parse("#{10.days.from_now.to_date} 8:30")
      select leave_date.day, from: 'itinerary_leave_date_3i'
      select I18n.t('date.month_names')[leave_date.month], from: 'itinerary_leave_date_2i'
      select leave_date.year, from: 'itinerary_leave_date_1i'
      select '08 AM', from: 'itinerary_leave_date_4i'
      select leave_date.min, from: 'itinerary_leave_date_5i'

      expect(page).to have_css('#itinerary_return_date_3i[disabled]')
      check 'itinerary_round_trip'
      expect(page).to_not have_css('#itinerary_return_date_3i[disabled]')

      return_date = Time.zone.parse("#{35.days.from_now.to_date} 9:10")
      select return_date.day, from: 'itinerary_return_date_3i'
      select I18n.t('date.month_names')[return_date.month], from: 'itinerary_return_date_2i'
      select return_date.year, from: 'itinerary_return_date_1i'
      select '09 AM', from: 'itinerary_return_date_4i'
      select return_date.min, from: 'itinerary_return_date_5i'

      fill_in 'itinerary_fuel_cost', with: '5'
      fill_in 'itinerary_tolls', with: '3'

      fill_in 'itinerary_description', with: 'MUSIC VERY LOUD!!!'
      check 'itinerary_pink'
      check 'itinerary_pets_allowed'
      click_button 'new_itinerary_submit'

      expect(page).to have_content I18n.t('flash.itineraries.success.create')
      expect(page).to have_content 'Milan'
      expect(page).to have_content 'Turin'
      expect(page).to have_content I18n.l(leave_date, format: :long)
      expect(page).to have_content I18n.l(return_date, format: :long)
      expect(page).to have_content '5.00'
      expect(page).to have_content '3.00'
      expect(page).to have_content Itinerary.human_attribute_name(:pink)
      expect(page).to have_content I18n.t('itineraries.header.pets.allowed')
      expect(page).to have_content I18n.t('itineraries.header.smoking.forbidden')
      expect(page).to have_content 'MUSIC VERY LOUD!!!'
    end

    it 'sanitize malicious description', js: true do
      login_as_male
      malicious_itinerary = FactoryGirl.create :itinerary, user: @user, description: XSS_ALERT
      visit itinerary_path(malicious_itinerary)
      expect(-> { page.driver.browser.switch_to.alert }).to raise_error Selenium::WebDriver::Error::NoAlertPresentError
    end

    it 'allow users to search them', js: true do
      login_as_male
      itinerary = FactoryGirl.create :itinerary, round_trip: true
      FactoryGirl.create :itinerary

      visit itineraries_path

      fill_in 'itineraries_search_from', with: 'Milan'
      fill_in 'itineraries_search_to', with: 'Turin'
      click_button 'itineraries-search'
      expect(page).to have_css('.itinerary-thumbnail', count: 2)
      within(".itinerary-thumbnail[data-itinerary-id=\"#{itinerary.id}\"]") do
        expect(page).to have_content itinerary.title
        expect(page).to have_content itinerary.user.to_s
        expect(page).to have_content I18n.l(itinerary.leave_date, format: :long)
        expect(page).to have_content I18n.l(itinerary.leave_date, format: :time_only)
        expect(page).to have_content I18n.l(itinerary.return_date, format: :long)
        expect(page).to have_content I18n.l(itinerary.return_date, format: :time_only)
      end
    end

    it 'allow users to view their own ones' do
      login_as_female
      FactoryGirl.create :itinerary, user: @user
      FactoryGirl.create :itinerary, user: @user, round_trip: true
      FactoryGirl.create :itinerary, user: @user, daily: true
      FactoryGirl.create :itinerary, user: @user, pink: true, daily: true

      visit itineraries_user_path(@user)

      expect(page).to have_css('tbody > tr', count: 4)
      @user.itineraries.each do |itinerary|
        row = find(:xpath, "//a[@href='#{itinerary_path(itinerary)}' and text()='#{itinerary.start_address}']/../..")
        expect(row).to_not be_nil
        expect(row).to have_css ROUND_TRIP_ICON if itinerary.round_trip?
        expect(row).to have_css DAILY_ICON if itinerary.daily?
        expect(row).to have_css PINK_ICON if itinerary.pink?
      end
    end

    it 'allow users to delete their own ones' do
      login_as_male
      itinerary = FactoryGirl.create :itinerary, user: @user

      visit itineraries_user_path(@user)

      find("a[data-method=\"delete\"][href=\"#{itinerary_path(itinerary)}\"]").click
      expect(page).to have_content I18n.t('flash.itineraries.success.destroy')
      expect(page).to_not have_content itinerary.title
    end

    it 'allow users to edit their own ones' do
      login_as_male
      itinerary = FactoryGirl.create :itinerary, user: @user, description: 'Old description'

      visit itineraries_user_path(@user)

      find("a[href=\"#{edit_itinerary_path(itinerary)}\"]").click
      fill_in 'itinerary_description', with: 'New Description'
      click_button I18n.t('helpers.submit.update', model: Itinerary.model_name.human)
      expect(page).to have_content I18n.t('flash.itineraries.success.update')
      expect(page).to have_content 'New Description'
    end

    it "doesn't allow male users to see pink itineraries" do
      login_as_male
      female_user = FactoryGirl.create :user, gender: 'female'
      pink_itinerary = FactoryGirl.create :itinerary, user: female_user, description: 'Pink itinerary', pink: true

      visit itinerary_path(pink_itinerary)

      expect(current_path).to eq dashboard_path
      expect(page).to have_content I18n.t('flash.itineraries.error.pink')
    end

    it 'does not fail when creating with wrong parameters' do
      login_as_male

      visit new_itinerary_path

      find('#new_itinerary_submit').click
      expect(page).to have_css '.alert-danger'
    end

    it 'does not fail when updating with wrong parameters' do
      login_as_male
      itinerary = FactoryGirl.create :itinerary, user: @user, description: 'Old description'

      visit itineraries_user_path(@user)

      find("a[href=\"#{edit_itinerary_path(itinerary)}\"]").click
      fill_in 'itinerary_description', with: ''
      click_button I18n.t('helpers.submit.update', model: Itinerary.model_name.human)
      expect(page).to have_css '.alert-danger'
    end
  end

  context 'Guests' do
    it 'allow guests to see itineraries' do
      user = FactoryGirl.create :user, name: 'John Doe', uid: '123456'
      itinerary = FactoryGirl.create :itinerary, description: 'Itinerary for guest users', user: user

      visit itinerary_path(itinerary)

      expect(current_path).to eq itinerary_path(itinerary)
      expect(page).to have_content itinerary.description
      expect(page).to_not have_content 'John Doe'
      expect(page).to_not have_css("img[src=\"http://graph.facebook.com/123456/picture?type=square\"]")
    end

    it "doesn't allow guests to see pink itineraries" do
      female_user = FactoryGirl.create :user, gender: 'female'
      pink_itinerary = FactoryGirl.create :itinerary, user: female_user, description: 'Pink itinerary', pink: true

      visit itinerary_path(pink_itinerary)

      expect(current_path).to eq root_path
    end
  end
end
