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

  describe 'RestrictedMode' do
    before(:all) do
      APP_CONFIG.facebook.set :restricted_group_id, '10'
    end

    after(:all) do
      APP_CONFIG.facebook.set :restricted_group_id, nil
    end

    it "blocks unauthorized users" do
      groups = [{ "name"=>"A group", "version"=>1, "id"=>"1", "administrator"=>true },
                { "name"=>"Another group", "version"=>1, "id"=>"2" }]
      stub_http_request(:get, /graph.facebook.com\/me/).to_return body: groups.to_json
      visit '/auth/facebook'
      expect(User.count).to be_zero
      expect(current_path).to eq root_path
      expect(page).to have_content I18n.t('flash.sessions.error.restricted')
    end

    it "allows authorized users" do
      groups = [{ "name"=>"A group", "version"=>1, "id"=>"1", "administrator"=>true },
                { "name"=>"ICARE GROUP", "version"=>1, "id"=>"10" }]
      stub_http_request(:get, /graph.facebook.com\/me/).to_return body: groups.to_json
      visit '/auth/facebook'
      expect(User.count).to_not be_zero
      expect(find("a[href='/signout']")).to be_present
    end

    it "sets admin attribute to group admins" do
      groups = [{ "name"=>"A group", "version"=>1, "id"=>"1" },
                { "name"=>"ICARE GROUP", "version"=>10, "id"=>"10", "administrator"=>true }]
      stub_http_request(:get, /graph.facebook.com\/me/).to_return body: groups.to_json
      visit '/auth/facebook'
      expect(User.count).to_not be_zero
      expect(find("a[href='/signout']")).to be_present
      expect(page).to have_css('#navbar-notifications-reports')
    end
  end
end
