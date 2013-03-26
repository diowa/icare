require 'spec_helper'

describe 'Conversations' do
  let(:driver) { FactoryGirl.create :user }
  let(:passenger) { FactoryGirl.create :user }
  let(:itinerary) { FactoryGirl.create :itinerary, user: driver }

  it "should be able to send messages" do
    user = FactoryGirl.create :user, uid: '123456', username: 'johndoe'
    message = 'can I come with you?'
    another_message = 'please please please!'
    visit '/auth/facebook'

    visit new_conversation_path(itinerary_id: itinerary.id)
    fill_in 'conversation_message_body', with: message
    click_button I18n.t('conversations.form.send')
    expect(page).to have_content message
    fill_in 'conversation_message_body', with: another_message
    expect(page).to have_content message
    expect(page).to have_content another_message
  end
end
