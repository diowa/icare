require 'spec_helper'

describe 'Feedbacks' do

  it "allows creation from registered users" do
    FactoryGirl.create :user, uid: '123456', username: 'johndoe'
    visit '/auth/facebook'
    click_link Feedback.model_name.human
    click_link I18n.t('helpers.links.new')
    fill_in 'feedback_message', with: 'This is a new feedback'
    click_button I18n.t('helpers.submit.create', model: Feedback)
    expect(current_path).to eq feedbacks_path
    expect(page).to have_content I18n.t('flash.feedbacks.success.create')
  end

  it "allows editing by owners" do
    user = FactoryGirl.create :user, uid: '123456', username: 'johndoe'
    feedback = FactoryGirl.create :feedback, user: user
    visit '/auth/facebook'
    visit feedback_path(feedback)
    click_link I18n.t('helpers.links.edit')
    fill_in 'feedback_message', with: 'This is a modified message'
    click_button I18n.t('helpers.submit.update', model: Feedback)
    expect(current_path).to eq feedbacks_path
    expect(page).to have_content I18n.t('flash.feedbacks.success.update')
    expect(feedback.reload.message).to eq 'This is a modified message'
  end

  it "allows editing by admins" do
    feedback = FactoryGirl.create :feedback
    FactoryGirl.create :user, uid: '123456', username: 'johndoe', admin: true
    visit '/auth/facebook'
    visit feedback_path(feedback)
    click_link I18n.t('helpers.links.edit')
    fill_in 'feedback_message', with: 'This is a modified message'
    click_button I18n.t('helpers.submit.update', model: Feedback)
    expect(current_path).to eq feedbacks_path
    expect(page).to have_content I18n.t('flash.feedbacks.success.update')
    expect(feedback.reload.message).to eq 'This is a modified message'
  end

  it "allows closing by admins" do
    feedback = FactoryGirl.create :feedback
    FactoryGirl.create :user, uid: '123456', username: 'johndoe', admin: true
    visit '/auth/facebook'
    visit feedback_path(feedback)
    click_link I18n.t('helpers.links.edit')
    select 'fixed', from: 'feedback_status'
    click_button I18n.t('helpers.submit.update', model: Feedback)
    expect(current_path).to eq feedbacks_path
    expect(page).to have_content I18n.t('flash.feedbacks.success.update')
    expect(feedback.reload.fixed?).to be_true
  end

  it "allows deletion by owners" do
    user = FactoryGirl.create :user, uid: '123456', username: 'johndoe'
    feedback = FactoryGirl.create :feedback, user: user
    visit '/auth/facebook'
    visit feedbacks_path
    find(:xpath, "//a[@data-method='delete' and @href='#{feedback_path(feedback)}']").click
    expect(current_path).to eq feedbacks_path
    expect(page).to have_content I18n.t('flash.feedbacks.success.destroy')
  end

  it "allows deletion by admins" do
    feedback = FactoryGirl.create :feedback
    FactoryGirl.create :user, uid: '123456', username: 'johndoe', admin: true
    visit '/auth/facebook'
    visit feedbacks_path
    find(:xpath, "//a[@data-method='delete' and @href='#{feedback_path(feedback)}']").click
    expect(current_path).to eq feedbacks_path
    expect(page).to have_content I18n.t('flash.feedbacks.success.destroy')
  end
end
