require 'spec_helper'

describe 'Authentication' do
  it "protects application pages from guest users" do
    visit '/dashboard'
    expect(page).to have_content I18n.t('flash.errors.not_authenticated')
  end

  it "allows users to sign in from Facebook" do
    visit '/auth/facebook'
    expect(find("a[href='/signout']")).to be_present
    expect(User.count).to_not be_zero
  end

  it "allows users to logout" do
    visit '/auth/facebook'
    expect(find("a[href='/signout']")).to be_present
    visit '/signout'
    expect(page).to have_content I18n.t('login_with_facebook')
  end

  it "redirects to itinerary viewed by guests" do
    itinerary = FactoryGirl.create :itinerary
    visit itinerary_path(itinerary)
    find('a', text: I18n.t('login_with_facebook')).click
    expect(page).to have_xpath '//title', itinerary.title
    expect(page).to have_content itinerary.user_name
  end

  it "redirects banned users to the banned page" do
    banned_user = FactoryGirl.create :user, banned: true, uid: '123456'
    visit '/auth/facebook'
    expect(current_path).to eq banned_path
    [itineraries_path, new_itinerary_path].each do |path|
      visit path
      expect(current_path).to eq banned_path
    end
  end
end
