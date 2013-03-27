require 'spec_helper'

describe 'References' do
  let(:driver) { FactoryGirl.create :user }
  let(:passenger) { FactoryGirl.create :user, uid: '123456', username: 'johndoe' }
  let(:itinerary) { FactoryGirl.create :itinerary, user: driver }

  it "should be able to send a reference" do
    body = 'Very good driver'
    visit '/auth/facebook'

    visit new_user_reference_path(passenger, itinerary_id: itinerary.id)
    fill_in 'reference_body', with: body
    choose('reference_rating_1')

    click_button I18n.t('helpers.submit.create', model: Reference.model_name.human)
    expect(page).to have_content body
  end
end