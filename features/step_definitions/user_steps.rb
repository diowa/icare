# encoding: utf-8
When /^a guest tries to access a protected page$/ do
  visit '/dashboard'
end

When /^a guest gives access permission to this application on Facebook$/ do
  OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
    provider: 'facebook',
    uid: '123456',
    info: {
      email: 'test@127.0.0.1',
      name: 'John Doe',
      first_name: 'John',
      last_name: 'Doe',
      image: 'http://graph.facebook.com/123456/picture?type=square',
      urls: { "Facebook" => "http://www.facebook.com/profile.php?id=123456" } },
    credentials: {
      token: "AAAGSwYCCrZCIBAFYjaLIVbD1ZCb2LqedQl4PWo8qBUTvWdi5uVSQM5uvLslz99mWRaYt9VHCa2ZCN8TtWZCZAYqeMr3hebVNmBFVVNAvT8gZDZD", 
      expires_at: 1361304575,
      expires: true },
    extra: {
      raw_info: {
        id: '123456',
        name: 'John Doe',
        first_name: 'John',
        last_name: 'Doe',
        link: 'http://www.facebook.com/profile.php?id=123456',
        birthday: '10/03/1981',
        work: [
          { employer: { id: '100', name: 'First Inc.' }, start_date: '0000-00' },
          { employer: { id: '101', name: 'Second Ltd.' }, start_date: '0000-00' },
          { employer: { id: '102', name: 'Third S.p.A.' }, start_date: '0000-00', end_date: '0000-00' }],
        favorite_athletes: [
          { id: '200', name: 'Fist Athlete' },
          { id: '201', name: 'Second Athlete' }],
        education: [
          { school: { id: '300', name: 'A College' }, type: 'College' }],
        gender: 'male',
        email: 'test@127.0.0.1',
        timezone: 1,
        locale: 'en_US',
        languages: [
          { id: '113153272032690', name: 'Italian' },
          { id: '106059522759137', name: 'English' },
          { id: '108224912538348', name: 'French' }],
        updated_time: '2012-12-16T08:49:27+0000' } } })
  visit '/auth/facebook'
end

Then /^he should see an? "([^"]*)" message "([^"]*)"$/ do |css_class, message|
  expect(page.find(".alert-#{css_class}")).to have_content(message)
end

Then /^he should not see an? "([^"]*)" message "([^"]*)"$/ do |css_class, message|
  lambda {page.find(".alert-#{css_class}")}.should raise_error(Capybara::ElementNotFound)
  page.should_not have_content(message)
end

Then /^he should fail to log in$/ do
  page.should have_content("Login failed, please retry.")
end

Then /^he should be logged in$/ do
  within(".navbar-inner") do
    expect(page.find("a[href='/signout']")).to be_present
  end
end

Then /^he should not be logged in$/ do
  within(".navbar-inner") do
    page.has_no_selector?("a[href='/logout']")
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

Then /^he should receive an activation email$/ do
  step "I should receive an email"
  step "I open the email"
  step "I should see \"activate\" in the email body"
end

Then /^he should receive a welcome email$/ do
  step "I should receive 2 emails"
  step "I open the email"
  step "I should see \"You have successfully signed up\" in the email body"
end

Then /^he should receive an email with a link to reset password$/ do
  step "I should receive 2 emails" #TODO Activation email turned off
  step "I open the email with subject \"Your password reset request\""
  step "I should see \"You have requested to reset your password.\" in the email body"
end
