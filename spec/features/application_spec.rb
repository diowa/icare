require 'spec_helper'

describe 'Application' do
  it "protects pages from guest users" do
    visit '/dashboard'
    expect(page).to have_content I18n.t('flash.errors.not_authenticated')
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
