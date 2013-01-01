When /^an admin logs in$/ do
  @admin = FactoryGirl.create :user, admin: true, uid: '123456', username: 'johndoe'
  visit '/auth/facebook'
end

Then /^he should see reports$/ do
  expect(find_by_id('navbar-notifications-reports')).to be_true
end

Then /^he should not see reports$/ do
  expect(-> { find('navbar-notifications-reports') }).to raise_error Capybara::ElementNotFound
end

Then /^he should not be allowed to view user index$/ do
  visit users_path
  step 'current uri should be dashboard_path'
end

Then /^he should be allowed to view user index$/ do
  visit users_path
  step 'current uri should be users_path'
end

Then /^he should be able to ban other users$/ do
  user_to_ban = FactoryGirl.create :user
  visit users_path
  find(:xpath, "//a[contains(@href, '#{ban_user_path(user_to_ban)}')]").click
  step 'he should see a "success" message "User successfully banned."'
  expect(find(:xpath, "//a[contains(@href, '#{unban_user_path(user_to_ban)}')]")).to be_true
end

Then /^he should not be able to ban himself$/ do
  visit users_path
  find(:xpath, "//a[contains(@href, '#{ban_user_path(@admin)}')]").click
  step 'he should see an "error" message "An error occurred while banning this user."'
end

Then /^he should be able to unban a banned user$/ do
  banned_user = FactoryGirl.create :user, banned: true
  visit users_path
  find(:xpath, "//a[contains(@href, '#{unban_user_path(banned_user)}')]").click
  step 'he should see a "success" message "User successfully unbanned."'
  expect(find(:xpath, "//a[contains(@href, '#{ban_user_path(banned_user)}')]")).to be_true
end
