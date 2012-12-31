# encoding: utf-8
When /^a guest tries to access a protected page$/ do
  visit '/dashboard'
end

When /^a guest gives access permission to this application on Facebook$/ do
  visit '/auth/facebook'
end

When /^a guest logs in on itinerary page$/ do
  @itinerary = FactoryGirl.create :itinerary
  visit itinerary_path(@itinerary)
  find('a', text: /Login with Facebook/i).click
end

When /^a user logs in$/ do
  @user = FactoryGirl.create :user, uid: '123456', username: 'johndoe'
  visit '/auth/facebook'
end

When /^a verified user logs in$/ do
  OmniAuth.config.mock_auth[:facebook] = OMNIAUTH_MOCKED_AUTHHASH.merge info: { verified: true }
  @user = FactoryGirl.create :user, uid: '123456', username: 'johndoe'
  visit '/auth/facebook'
end

When /^a banned user logs in$/ do
  @banned_user = FactoryGirl.create :user, banned: true, uid: '123456'
  visit '/auth/facebook'
end

Then /^current uri should be ([a-z_]+)$/ do |path|
  uri = URI.parse current_url
  expect(uri.path).to eq Rails.application.routes.url_helpers.send(path.to_sym)
end

Then /^he should be redirected to the banned page$/ do
  step 'current uri should be banned_path'
end

Then /^he should not be able to view any other page$/ do
  visit itineraries_path
  step 'current uri should be banned_path'
  visit new_itinerary_path
  step 'current uri should be banned_path'
end

Then /^he should be redirected to the itinerary page$/ do
  expect(page).to have_xpath '//title', @itinerary.title
  expect(page).to have_content @itinerary.user_name
end

Then /^he should see an? "([^"]*)" message "([^"]*)"$/ do |css_class, message|
  expect(find(".alert-#{css_class}")).to have_content message
end

Then /^he should not see an? "([^"]*)" message "([^"]*)"$/ do |css_class, message|
  expect(-> { find(".alert-#{css_class}") }).to raise_error Capybara::ElementNotFound
  page.should_not have_content message
end

Then /^he should fail to log in$/ do
  page.should have_content 'Login failed, please retry.'
end

Then /^he should be logged in$/ do
  within('.navbar-inner') do
    expect(find("a[href='/signout']")).to be_present
  end
end

Then /^he should not be logged in$/ do
  within('.navbar-inner') do
    page.has_no_selector? "a[href='/logout']"
  end
end

Then /^a new user should be added to database$/ do
  expect(User.count).to_not be_zero
end

Then /^he should be able to log out$/ do
  visit '/signout'
end

Then /^he should see the log in button$/ do
  expect(page).to have_content 'Login with Facebook'
end
