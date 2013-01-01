When /^a user with references logs in$/ do
  step 'a user logs in'
  itinerary = FactoryGirl.create :itinerary, user: @user

  passengers = 6.times.map { |_| FactoryGirl.create :user }

  # 1 negative reference
  reference = FactoryGirl.create :reference, user: passengers.first, itinerary: itinerary
  FactoryGirl.build :outgoing_reference, reference: reference, rating: -1, body: 'Negative'
  reference.save

  # 2 neutral references
  passengers[1..2].each do |passenger|
    reference = FactoryGirl.create :reference, user: passenger, itinerary: itinerary
    FactoryGirl.build :outgoing_reference, reference: reference, rating: 0, body: 'Neutral'
    reference.save
  end

  # 3 negative references
  passengers[3..5].each do |passenger|
    reference = FactoryGirl.create :reference, user: passenger, itinerary: itinerary
    FactoryGirl.build :outgoing_reference, reference: reference
    reference.save
  end
  @user.reload

  visit '/auth/facebook'
end

When /^he visit his profile$/ do
  visit user_path(@user)
end

Then /^he should see the verified box$/ do
  expect(find('.facebook-verified')).to be_true
end

Then /^he should see his references$/ do
  expect(has_content?(I18n.t('references.snippet.positives', count: @user.references.positives.count))).to be_true  
  expect(has_content?(I18n.t('references.snippet.neutrals', count: @user.references.neutrals.count))).to be_true  
  expect(has_content?(I18n.t('references.snippet.negatives', count: @user.references.negatives.count))).to be_true  
end
