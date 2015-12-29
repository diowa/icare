require 'spec_helper'

describe 'Feedbacks' do
  it 'allows creation from registered users' do
    FactoryGirl.create :user, uid: '123456', username: 'johndoe'

    visit user_omniauth_authorize_path(provider: :facebook)

    click_link Feedback.model_name.human
    click_link I18n.t('helpers.links.new')
    fill_in 'feedback_message', with: 'This is a new feedback'
    click_button I18n.t('helpers.submit.create', model: Feedback)
    expect(current_path).to eq feedbacks_path
    expect(page).to have_content I18n.t('flash.feedbacks.success.create')
  end

  it 'allows editing by owners' do
    user = FactoryGirl.create :user, uid: '123456', username: 'johndoe'
    feedback = FactoryGirl.create :feedback, user: user

    visit user_omniauth_authorize_path(provider: :facebook)
    visit feedback_path(feedback)

    click_link I18n.t('helpers.links.edit')
    fill_in 'feedback_message', with: 'This is a modified message'
    click_button I18n.t('helpers.submit.update', model: Feedback)
    expect(current_path).to eq feedbacks_path
    expect(page).to have_content I18n.t('flash.feedbacks.success.update')
    expect(feedback.reload.message).to eq 'This is a modified message'
  end

  it 'allows editing by admins' do
    feedback = FactoryGirl.create :feedback
    FactoryGirl.create :user, uid: '123456', username: 'johndoe', admin: true

    visit user_omniauth_authorize_path(provider: :facebook)
    visit feedback_path(feedback)

    click_link I18n.t('helpers.links.edit')
    fill_in 'feedback_message', with: 'This is a modified message'
    click_button I18n.t('helpers.submit.update', model: Feedback)
    expect(current_path).to eq feedbacks_path
    expect(page).to have_content I18n.t('flash.feedbacks.success.update')
    expect(feedback.reload.message).to eq 'This is a modified message'
  end

  it 'allows closing by admins' do
    feedback = FactoryGirl.create :feedback
    FactoryGirl.create :user, uid: '123456', username: 'johndoe', admin: true

    visit user_omniauth_authorize_path(provider: :facebook)
    visit feedback_path(feedback)

    click_link I18n.t('helpers.links.edit')
    select 'fixed', from: 'feedback_status'
    click_button I18n.t('helpers.submit.update', model: Feedback)
    expect(current_path).to eq feedbacks_path
    expect(page).to have_content I18n.t('flash.feedbacks.success.update')
    expect(feedback.reload.fixed?).to be true
  end

  it 'allows deletion by owners' do
    user = FactoryGirl.create :user, uid: '123456', username: 'johndoe'
    feedback = FactoryGirl.create :feedback, user: user

    visit user_omniauth_authorize_path(provider: :facebook)
    visit feedbacks_path

    find("a[data-method=\"delete\"][href=\"#{feedback_path(feedback)}\"]").click
    expect(current_path).to eq feedbacks_path
    expect(page).to have_content I18n.t('flash.feedbacks.success.destroy')
  end

  it 'allows deletion by admins' do
    feedback = FactoryGirl.create :feedback
    FactoryGirl.create :user, uid: '123456', username: 'johndoe', admin: true

    visit user_omniauth_authorize_path(provider: :facebook)
    visit feedbacks_path

    find("a[data-method=\"delete\"][href=\"#{feedback_path(feedback)}\"]").click
    expect(current_path).to eq feedbacks_path
    expect(page).to have_content I18n.t('flash.feedbacks.success.destroy')
  end

  it "doesn't fail when user deletes their account" do
    FactoryGirl.create :user, uid: '123456', username: 'johndoe'
    feedback = FactoryGirl.create :feedback
    former_user_feedback = FactoryGirl.create :feedback
    former_user_feedback.user.destroy

    visit user_omniauth_authorize_path(provider: :facebook)
    visit feedbacks_path

    expect(page).to have_content feedback.user
    expect(page).to have_content I18n.t('former_user')
  end

  it "doesn't fail when creating with wrong parameters" do
    FactoryGirl.create :user, uid: '123456', username: 'johndoe'

    visit user_omniauth_authorize_path(provider: :facebook)
    visit new_feedback_path

    click_button I18n.t('helpers.submit.create', model: Feedback)
    expect(page).to have_css '.alert-danger'
  end

  it "doesn't fail when updating with wrong parameters" do
    user = FactoryGirl.create :user, uid: '123456', username: 'johndoe'
    feedback = FactoryGirl.create :feedback, user: user

    visit user_omniauth_authorize_path(provider: :facebook)
    visit edit_feedback_path(feedback)
    fill_in 'feedback_message', with: ''
    click_button I18n.t('helpers.submit.update', model: Feedback)
    expect(page).to have_css '.alert-danger'
  end
end
