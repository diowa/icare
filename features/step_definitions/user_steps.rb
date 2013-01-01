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

When /^he visit another user with common languages$/ do
  @user_with_common_languages = FactoryGirl.create :user, languages: [{ id: '106059522759137', name: 'English' }]
  visit user_path(@user_with_common_languages)
end

When /^he visit another user with a common work$/ do
  @user_with_common_works = FactoryGirl.create :user, work: [ { employer: { id: '100', name: 'First Inc.' }, start_date: '0000-00' } ]
  visit user_path(@user_with_common_works)
end

When /^he visit another user with a common education$/ do
  @user_with_common_education = FactoryGirl.create :user, education: [{ school: { id: '300', name: 'A College' }, type: 'College' }]
  visit user_path(@user_with_common_education)
end

When /^he visit another user with mutual friends$/ do
  mutual_friends = 6.times.map { |i| { 'id' => "90110#{i}", 'name' => "Mutual friend named #{i}" } }
  @user.update_attribute :facebook_friends, [{ 'id' => '900100', 'name' => 'Not a mutual friend' },
                                             { 'id' => '900101', 'name' => 'Not a mutual friend' }] + mutual_friends
  @user.reload
  @user_with_mutual_friends = FactoryGirl.create :user,
                                                 facebook_friends: [{ 'id' => '910100', 'name' => 'Not a mutual friend' }, { 'id' => '910101', 'name' => 'Not a mutual friend' } ] + mutual_friends
  visit user_path(@user_with_mutual_friends)
end

When /^he visit another user with common likes$/ do
  @user.update_attribute :facebook_favorites, [ { 'id' => '1900100', 'name' => 'Not a common like' }, { 'id' => '1900102', 'name' => 'Common like' } ]
  @user.reload
  @user_with_common_friends = FactoryGirl.create :user,
                                                 facebook_favorites: [ { 'id' => '1910100', 'name' => 'Not a common like' }, { 'id' => '1900102', 'name' => 'Common like' } ]
  visit user_path(@user_with_common_friends)
end


Then /^he should see his references$/ do
  expect(has_content?(I18n.t('references.snippet.positives', count: @user.references.positives.count))).to be_true
  expect(has_content?(I18n.t('references.snippet.neutrals', count: @user.references.neutrals.count))).to be_true
  expect(has_content?(I18n.t('references.snippet.negatives', count: @user.references.negatives.count))).to be_true
end

Then /^he should see common languages highlighted$/ do
  expect(find(:xpath, "//span[@class='common' and text()='#{I18n.t('users.show.language', language: 'English')}']")).to be_true
end

Then /^he should see common work highlighted$/ do
  expect(find(:xpath, "//span[@class='common' and text()='First Inc.']")).to be_true
end

Then /^he should see common education highlighted$/ do
  expect(find(:xpath, "//span[@class='common' and text()='A College']")).to be_true
end

Then /^he should see mutual friends$/ do
  expect(all(:xpath, "//span[text()[contains(.,'Mutual friend named ')]]").size).to be 5
  expect(has_content?(I18n.t('users.show.and_others', count: 1))).to be_true
  expect(has_content?('Not a common friend')).to be_false
end

Then /^he should see common likes highlighted$/ do
  expect(find(:xpath, "//span[@class='common' and text()='Common like']")).to be_true
  expect(-> { find(:xpath, "//span[@class='common' and text()='Not a common like']") }).to raise_error Capybara::ElementNotFound
end

Then /^he should see his friends with privacy$/ do
  expect(find(:xpath, "//span[text()='#{I18n.t('users.show.friends', count: '10-')}']")).to be_true
  step 'create 6 friends and refresh'
  expect(find(:xpath, "//span[text()='#{I18n.t('users.show.friends', count: '10-')}']")).to be_true
  step 'create 11 friends and refresh'
  expect(find(:xpath, "//span[text()='#{I18n.t('users.show.friends', count: '10+')}']")).to be_true
  step 'create 101 friends and refresh'
  expect(find(:xpath, "//span[text()='#{I18n.t('users.show.friends', count: '100+')}']")).to be_true
  step 'create 1001 friends and refresh'
  expect(find(:xpath, "//span[text()='#{I18n.t('users.show.friends', count: '1000+')}']")).to be_true
  step 'create 5001 friends and refresh'
  expect(find(:xpath, "//span[text()='#{I18n.t('users.show.friends', count: '5000')}']")).to be_true
end

Then /^create (\d+) friends and refresh$/ do |n|
  @user.update_attribute :facebook_friends, n.to_i.times.map { |i| { 'id' => "90110#{i}", 'name' => "Friend #{i}" } }
  @user.reload
  visit user_path(@user)
end
