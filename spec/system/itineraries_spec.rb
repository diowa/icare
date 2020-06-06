# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Itineraries' do
  let(:male) { create :user, uid: '123456', gender: 'male' }
  let(:female) { create :user, uid: '123456', gender: 'female' }

  let(:xss_alert) { "<script>alert('toasty!);</script>" }

  shared_examples 'feature icons' do |options|
    options.each do |feature, icon|
      it "shows #{feature} icon" do
        login_as_female
        create :itinerary, user: female, "#{feature}": true

        visit itineraries_user_path(female)

        within '.table-itinerary' do
          expect(page).to have_css icon
        end
      end
    end
  end

  context 'with registered Users' do
    def login_as_male
      male
      login_via_facebook
      # NOTE: without the below line, the first test will fail, like it didn't vist the authentication link
      expect(page).to have_current_path dashboard_path
    end

    def login_as_female
      female
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH.merge info: { name: 'Johanna Doe' }, extra: { raw_info: { gender: 'female' } }
      login_via_facebook
      # NOTE: without the below line, the first test will fail, like it didn't vist the authentication link
      expect(page).to have_current_path dashboard_path
    ensure
      OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH
    end

    it 'are allowed to create itineraries', js: true, skip: ENV['CI'] do
      login_as_female

      visit new_itinerary_path

      fill_in 'itinerary_start_address', with: 'Milan'
      fill_in 'itinerary_end_address', with: 'Turin'
      click_button 'get-route'

      Timeout.timeout(5) do
        sleep(0.1) until page.evaluate_script('$("#map-result-j #distance").text().trim()') != ''
      end

      click_button 'wizard-next-step-button'

      leave_date = Time.zone.parse("#{10.days.from_now.to_date} 8:30")
      select leave_date.day.to_s, from: 'itinerary_leave_date_3i'
      select t('date.month_names')[leave_date.month], from: 'itinerary_leave_date_2i'
      select leave_date.year.to_s, from: 'itinerary_leave_date_1i'
      select '08 AM', from: 'itinerary_leave_date_4i'
      select leave_date.min.to_s, from: 'itinerary_leave_date_5i'

      expect(page).to have_css('#itinerary_return_date_3i[disabled]')
      check 'itinerary_round_trip'
      expect(page).not_to have_css('#itinerary_return_date_3i[disabled]')

      return_date = Time.zone.parse("#{35.days.from_now.to_date} 9:10")
      select return_date.day.to_s, from: 'itinerary_return_date_3i'
      select t('date.month_names')[return_date.month], from: 'itinerary_return_date_2i'
      select return_date.year.to_s, from: 'itinerary_return_date_1i'
      select '09 AM', from: 'itinerary_return_date_4i'
      select return_date.min.to_s, from: 'itinerary_return_date_5i'

      fill_in 'itinerary_fuel_cost', with: '5'
      fill_in 'itinerary_tolls', with: '3'

      fill_in 'itinerary_description', with: 'MUSIC VERY LOUD!!!'
      find('label[for="itinerary_pink"]').click
      find('label[for="itinerary_pets_allowed"]').click
      click_button 'new_itinerary_submit-j'

      expect(page).to have_content t('flash.itineraries.success.create')
      expect(page).to have_content 'Milan'
      expect(page).to have_content 'Turin'
      expect(page).to have_content I18n.l(leave_date, format: :long)
      expect(page).to have_content I18n.l(return_date, format: :long)
      expect(page).to have_content '5.00'
      expect(page).to have_content '3.00'
      expect(page).to have_content Itinerary.human_attribute_name(:pink)
      expect(page).to have_content t('itineraries.header.pets.allowed')
      expect(page).to have_content t('itineraries.header.smoking.forbidden')
      expect(page).to have_content 'MUSIC VERY LOUD!!!'
    end

    it 'sanitize malicious description', js: true, skip: ENV['CI'] do
      login_as_male
      malicious_itinerary = create :itinerary, user: male, description: xss_alert
      visit itinerary_path(malicious_itinerary)
      expect { page.accept_alert }.to raise_error Capybara::ModalNotFound
    end

    it 'allows users to search them', js: true, skip: ENV['CI'] do
      # TODO: fix time zone issues
      login_as_male

      itinerary = create :itinerary, round_trip: true, leave_date: 1.day.from_now.utc
      create :itinerary, leave_date: 2.days.from_now

      visit itineraries_path

      fill_in 'itineraries_search_from', with: 'Milan'
      fill_in 'itineraries_search_to', with: 'Turin'
      click_button 'itineraries-search'
      expect(page).to have_css('.itinerary-thumbnail', count: 2)
      within(".itinerary-thumbnail[data-itinerary-id=\"#{itinerary.id}\"]") do
        expect(page).to have_content itinerary.title
        expect(page).to have_content itinerary.user.to_s
        expect(page).to have_content I18n.l(itinerary.leave_date.to_date, format: :long)
        expect(page).to have_content I18n.l(itinerary.return_date.to_date, format: :long)

        # expect(page).to have_content I18n.l(itinerary.leave_date, format: :time_only)
        # expect(page).to have_content I18n.l(itinerary.return_date, format: :time_only)
      end
    end

    it 'allows users to view their own ones' do
      login_as_female
      create_list :itinerary, 2, user: female

      visit itineraries_user_path(female)

      expect(page).to have_css('tbody > tr', count: 2)
    end

    include_examples 'feature icons', daily:           '.fa-redo',
                                      pets_allowed:    '.fa-paw',
                                      pink:            '.fa-lock',
                                      round_trip:      '.fa-exchange-alt',
                                      smoking_allowed: '.fa-smoking'

    it 'allows users to delete their own ones' do
      login_as_male
      itinerary = create :itinerary, user: male

      visit itineraries_user_path(male)

      find("a[data-method=\"delete\"][href=\"#{itinerary_path(itinerary)}\"]").click

      expect(page).to have_content t('flash.itineraries.success.destroy')
      expect(page).not_to have_content itinerary.title
    end

    it 'allows users to edit their own ones' do
      login_as_male
      itinerary = create :itinerary, user: male, description: 'Old description'

      visit itineraries_user_path(male)

      find("a[href=\"#{edit_itinerary_path(itinerary)}\"]").click
      fill_in 'itinerary_description', with: 'New Description'
      click_button t('helpers.submit.update', model: Itinerary.model_name.human)
      expect(page).to have_content t('flash.itineraries.success.update')
      expect(page).to have_content 'New Description'
    end

    it "doesn't allow male users to see pink itineraries" do
      login_as_male
      female_user = create :user, gender: 'female'
      pink_itinerary = create :itinerary, user: female_user, description: 'Pink itinerary', pink: true

      visit itinerary_path(pink_itinerary)

      expect(page).to have_current_path dashboard_path
      expect(page).to have_content t('flash.itineraries.error.pink')
    end

    it 'does not fail when creating with wrong parameters' do
      login_as_male

      visit new_itinerary_path

      find('#new_itinerary_submit-j').click
      expect(page).to have_css '.alert-danger'
    end

    it 'does not fail when updating with wrong parameters' do
      login_as_male
      itinerary = create :itinerary, user: male, description: 'Old description'

      visit itineraries_user_path(male)

      find("a[href=\"#{edit_itinerary_path(itinerary)}\"]").click
      fill_in 'itinerary_description', with: ''
      click_button t('helpers.submit.update', model: Itinerary.model_name.human)
      expect(page).to have_css '.alert-danger'
    end
  end

  context 'with guests' do
    it 'allows guests to see itineraries' do
      user = create :user, name: 'John Doe', uid: '123456'
      itinerary = create :itinerary, description: 'Itinerary for guest users', user: user

      visit itinerary_path(itinerary)

      expect(page).to have_current_path itinerary_path(itinerary)
      expect(page).to have_content itinerary.description
      expect(page).not_to have_content 'John Doe'
      expect(page).not_to have_css('img[src="http://graph.facebook.com/123456/picture?type=square"]')
    end

    it "doesn't allow guests to see pink itineraries" do
      female_user = create :user, gender: 'female'
      pink_itinerary = create :itinerary, user: female_user, description: 'Pink itinerary', pink: true

      visit itinerary_path(pink_itinerary)

      expect(page).to have_current_path root_path
    end
  end
end
