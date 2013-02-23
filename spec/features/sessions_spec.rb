require 'spec_helper'

describe 'Sessions' do
  it "allow users to sign in from Facebook" do
    visit '/auth/facebook'
    expect(find("a[href='/signout']")).to be_present
    expect(User.count).to_not be_zero
  end

  it "allow users to logout" do
    visit '/auth/facebook'
    expect(find("a[href='/signout']")).to be_present
    visit '/signout'
    expect(page).to have_content I18n.t('login_with_facebook')
  end

  it "redirect to itinerary viewed by guests" do
    itinerary = FactoryGirl.create :itinerary
    visit itinerary_path(itinerary)
    find('a', text: I18n.t('login_with_facebook')).click
    expect(page).to have_xpath '//title', itinerary.title
    expect(page).to have_content itinerary.user_name
  end
end
