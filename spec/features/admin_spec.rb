require 'spec_helper'

describe 'Admin' do
  before(:each) do
    @admin = FactoryGirl.create :user, admin: true, uid: '123456', username: 'johndoe'

    visit user_omniauth_authorize_path(provider: :facebook)
  end

  #   it "sees reports" do
  #     expect(page).to have_css('#navbar-notifications-reports')
  #   end

  it 'sees users index' do
    visit admin_users_path

    expect(current_path).to eq admin_users_path
  end

  it 'is able to ban other users' do
    user_to_ban = FactoryGirl.create :user

    visit admin_users_path

    find("a[href=\"#{ban_admin_user_path(user_to_ban.id)}\"]").click
    expect(page).to have_content I18n.t('flash.admin.users.success.ban')
    expect(page).to have_css "a[href=\"#{unban_admin_user_path(user_to_ban.id)}\"]"
  end

  it 'is not able to ban himself' do
    visit admin_users_path

    find("a[href=\"#{ban_admin_user_path(@admin.id)}\"]").click
    expect(page).to have_content I18n.t('flash.admin.users.error.ban')
  end

  it 'is not able to unban banned users' do
    banned_user = FactoryGirl.create :user, banned: true

    visit admin_users_path

    find("a[href=\"#{unban_admin_user_path(banned_user.id)}\"]").click
    expect(page).to have_content I18n.t('flash.admin.users.success.unban')
    expect(page).to have_css "a[href=\"#{ban_admin_user_path(banned_user.id)}\"]"
  end

  it 'could login as another user' do
    regular_user = FactoryGirl.create :user, name: 'act_as_me'

    visit login_as_admin_user_path(regular_user.id)

    expect(current_path).to eq dashboard_path
    expect(page).to have_content regular_user.name
  end
end
