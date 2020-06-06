# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Feedbacks' do
  it 'allows creation from registered users' do
    create :user, uid: '123456'

    login_via_facebook

    click_link Feedback.model_name.human
    click_link t('helpers.links.new')
    fill_in 'feedback_message', with: 'This is a new feedback'
    click_button t('helpers.submit.create', model: Feedback)
    expect(page).to have_current_path feedbacks_path
    expect(page).to have_content t('flash.feedbacks.success.create')
  end

  it 'allows editing by owners' do
    user = create :user, uid: '123456'
    feedback = create :feedback, user: user

    login_via_facebook
    visit feedback_path(feedback)

    click_link t('helpers.links.edit')
    fill_in 'feedback_message', with: 'This is a modified message'
    click_button t('helpers.submit.update', model: Feedback)
    expect(page).to have_current_path feedbacks_path
    expect(page).to have_content t('flash.feedbacks.success.update')
    expect(feedback.reload.message).to eq 'This is a modified message'
  end

  it 'allows editing by admins' do
    feedback = create :feedback
    create :user, uid: '123456', admin: true

    login_via_facebook
    visit feedback_path(feedback)

    click_link t('helpers.links.edit')
    fill_in 'feedback_message', with: 'This is a modified message'
    click_button t('helpers.submit.update', model: Feedback)
    expect(page).to have_current_path feedbacks_path
    expect(page).to have_content t('flash.feedbacks.success.update')
    expect(feedback.reload.message).to eq 'This is a modified message'
  end

  it 'allows closing by admins' do
    feedback = create :feedback
    create :user, uid: '123456', admin: true

    login_via_facebook
    visit feedback_path(feedback)

    click_link t('helpers.links.edit')
    select 'fixed', from: 'feedback_status'
    click_button t('helpers.submit.update', model: Feedback)
    expect(page).to have_current_path feedbacks_path
    expect(page).to have_content t('flash.feedbacks.success.update')
    expect(feedback.reload.fixed?).to be true
  end

  it 'allows deletion by owners' do
    user = create :user, uid: '123456'
    feedback = create :feedback, user: user

    login_via_facebook
    visit feedbacks_path

    find("a[data-method=\"delete\"][href=\"#{feedback_path(feedback)}\"]").click

    expect(page).to have_current_path feedbacks_path
    expect(page).to have_content t('flash.feedbacks.success.destroy')
  end

  it 'allows deletion by admins' do
    feedback = create :feedback
    create :user, uid: '123456', admin: true

    login_via_facebook
    visit feedbacks_path

    find("a[data-method=\"delete\"][href=\"#{feedback_path(feedback)}\"]").click

    expect(page).to have_current_path feedbacks_path
    expect(page).to have_content t('flash.feedbacks.success.destroy')
  end

  it "doesn't fail when user deletes their account" do
    create :user, uid: '123456'
    feedback = create :feedback
    former_user_feedback = create :feedback
    former_user_feedback.user.destroy

    login_via_facebook
    visit feedbacks_path

    expect(page).to have_content feedback.user
    expect(page).to have_content t('former_user')
  end

  it "doesn't fail when creating with wrong parameters" do
    create :user, uid: '123456'

    login_via_facebook
    visit new_feedback_path

    click_button t('helpers.submit.create', model: Feedback)
    expect(page).to have_css '.alert-danger'
  end

  it "doesn't fail when updating with wrong parameters" do
    user = create :user, uid: '123456'
    feedback = create :feedback, user: user

    login_via_facebook
    visit edit_feedback_path(feedback)
    fill_in 'feedback_message', with: ''
    click_button t('helpers.submit.update', model: Feedback)
    expect(page).to have_css '.alert-danger'
  end
end
