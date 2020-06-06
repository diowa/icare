# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Conversations' do
  let(:driver) { create :user }
  let(:passenger) { create :user, uid: '123456' }
  let(:itinerary) { create :itinerary, user: driver }

  it 'allows to see own notifications' do
    receiver = create :user, uid: '123456'
    sender = create :user, name: 'Message Sender'
    itinerary = create :itinerary, user: receiver
    conversation = create :conversation, sender: sender, receiver: receiver, conversable: itinerary
    conversation.messages << build(:message, sender: sender, body: "<script>alert('toasty!);</script>")
    conversation.save

    login_via_facebook
    visit conversations_path

    expect(page).to have_content 'Message Sender'
    expect(page).to have_css "a[href=\"#{conversation_path(conversation)}\"]"
  end

  it 'allows to send messages' do
    message = 'can I come with you?'
    another_message = 'please please please!'

    login_via_facebook
    visit new_conversation_path(itinerary_id: itinerary.id)

    fill_in 'conversation_message_body', with: message
    click_button t('conversations.form.send')
    expect(page).to have_content message
    fill_in 'conversation_message_body', with: another_message
    click_button t('conversations.form.send')
    expect(page).to have_content message
    expect(page).to have_content another_message
  end

  it 'rescues from creation errors' do
    login_via_facebook
    visit new_conversation_path(itinerary_id: itinerary.id)

    click_button t('conversations.form.send')

    expect(page).to have_css '.alert-danger'
  end

  it 'rescues from update errors' do
    receiver = create :user, uid: '123456'
    sender = create :user
    itinerary = create :itinerary, user: receiver
    conversation = create :conversation, sender: sender, receiver: receiver, conversable: itinerary
    conversation.messages << build(:message, sender: sender, body: "<script>alert('toasty!);</script>")
    conversation.save

    login_via_facebook
    visit conversation_path(conversation, itinerary_id: itinerary.id)

    click_button t('conversations.form.send')

    expect(page).to have_css '.alert-danger'
  end

  it 'displays unread messages in the navbar', js: true, skip: ENV['CI'] do
    receiver = create :user, uid: '123456'
    sender = create :user
    itinerary = create :itinerary, user: receiver
    conversation = create :conversation, sender: sender, receiver: receiver, conversable: itinerary
    conversation.messages << build(:message, sender: sender, body: "<script>alert('toasty!);</script>")
    conversation.save

    login_via_facebook

    within('.navbar-notifications') do
      expect(page).to have_css '.unread-count'
      expect(page).to have_xpath "//span[@class='unread-count' and text()='1']"
      find('#notifications-conversations > a').click
      within('.popover') do
        expect(page).to have_content sender.to_s
        expect(page).to have_content "<script>alert('toasty!);</script>"
        expect { page.accept_alert }.to raise_error Capybara::ModalNotFound
      end
    end
  end

  context 'when visiting unread' do
    it 'redirects to conversations path' do
      login_via_facebook

      visit unread_conversations_path

      expect(page).to have_current_path conversations_path
    end
  end
end
