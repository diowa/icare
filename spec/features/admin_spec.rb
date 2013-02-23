require 'spec_helper'

describe 'Admin' do
  before(:each) do
    @admin = FactoryGirl.create :user, admin: true, uid: '123456', username: 'johndoe'
    visit '/auth/facebook'
  end

  it "should see reports" do
    expect(page).to have_css('#navbar-notifications-reports')
  end

  it "should see users index" do
    visit users_path
    expect(current_path).to eq users_path
  end

  it "should be able to ban other users" do
    user_to_ban = FactoryGirl.create :user
    visit users_path
    find(:xpath, "//a[contains(@href, '#{ban_user_path(user_to_ban)}')]").click
    expect(page).to have_content I18n.t('flash.users.success.ban')
    expect(find(:xpath, "//a[contains(@href, '#{unban_user_path(user_to_ban)}')]")).to be_true
  end

  it "should not be able to ban himself" do
    visit users_path
    find(:xpath, "//a[contains(@href, '#{ban_user_path(@admin)}')]").click
    expect(page).to have_content I18n.t('flash.users.error.ban')
  end

  it "should not be able to unban banned users" do
    banned_user = FactoryGirl.create :user, banned: true
    visit users_path
    find(:xpath, "//a[contains(@href, '#{unban_user_path(banned_user)}')]").click
    expect(page).to have_content I18n.t('flash.users.success.unban')
    expect(find(:xpath, "//a[contains(@href, '#{ban_user_path(banned_user)}')]")).to be_true
  end
end
