When /^a guest tries to access a protected page$/ do
  @user = FactoryGirl.create(:user)
  visit("/users/#{@user.id}/edit")
end

When /^a guest tries to access Icare through facebook$/ do
  visit("/auth/facebook")
end

When /^he should be redirected on facebook's website$/ do
  #page.current_url.should match /^https:\/\/www.facebook.com\/.+/
  #page.should have_content("Facebook Login")
end

When /^a guest gives access permission to this application on facebook$/ do
  #visit("/oauth/callback?provider=facebook&code=AQDA-6SZd_pAJFGZuzysxPZkPQKE5I9BdujhAp-2WJvnhqWIZiUwJG8gXdATUSxptzkBoOrkHsG-fjIS4zID-kEw55tUVWlxPacT3Tq2EOaiMB_quT7ZHf8bHjXpaSFzDQL0FILwJNC65B4SKabGfqiWYyL3l6bRwaIx5T1lJXei22DdBEKEW_TfbOl5wmuDuUA")
end

When /^he tries to logout$/ do
  visit("/logout")
end

Then /^he should see an? "([^"]*)" message "([^"]*)"$/ do |css_class, message|
  page.find(".alert-#{css_class}").should have_content(message)
end

Then /^he should not see an? "([^"]*)" message "([^"]*)"$/ do |css_class, message|
  lambda {page.find(".alert-#{css_class}")}.should raise_error(Capybara::ElementNotFound)
  page.should_not have_content(message)
end

Then /^he should fail to log in$/ do
  page.should have_content("Login failed, please retry.")
end

Then /^he should be logged in$/ do
  #within(".navbar-inner") do
  #  page.find("a[href='/logout']").should be_present
  #end
end

Then /^he should not be logged in$/ do
  within(".navbar-inner") do
    page.has_no_selector?("a[href='/logout']")
  end
end

Then /^a new user should be added to database$/ do
  #User.count.should_not eql 0
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
