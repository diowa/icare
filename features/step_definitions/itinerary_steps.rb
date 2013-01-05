ROUND_TRIP_ICON = 'icon-exchange'
DAILY_ICON = 'icon-repeat'
PINK_ICON = 'icon-lock'

When /^a male user with itineraries logs in$/ do
  @user = FactoryGirl.create :user, uid: '123456', gender: 'male'
  FactoryGirl.create :itinerary, user: @user
  FactoryGirl.create :itinerary, user: @user, round_trip: true
  FactoryGirl.create :itinerary, user: @user, daily: true
  visit '/auth/facebook'
end

When /^a female user with itineraries and pink itineraries logs in$/ do
  @user = FactoryGirl.create :user, uid: '123456', gender: 'female'
  FactoryGirl.create :itinerary, user: @user
  FactoryGirl.create :itinerary, user: @user, round_trip: true
  FactoryGirl.create :itinerary, user: @user, daily: true
  FactoryGirl.create :itinerary, user: @user, pink: true, daily: true
  visit '/auth/facebook'
end

Then /^(he|she) should be able to manage (his|her) itineraries$/ do |_, _|
  visit itineraries_user_path @user
  @user.itineraries.each do |itinerary|
    row = find(:xpath, "//a[@href='#{itinerary_path(itinerary)}' and text()='#{itinerary.title}']/../..")
    expect(row).to_not be_nil
    expect(row.find(:xpath, ".//i[contains(@class,'#{ROUND_TRIP_ICON}')]")).to_not be_nil if itinerary.round_trip?
    expect(row.find(:xpath, ".//i[contains(@class,'#{DAILY_ICON}')]")).to_not be_nil if itinerary.daily?
    expect(row.find(:xpath, ".//i[contains(@class,'#{PINK_ICON}')]")).to_not be_nil if itinerary.pink?
  end
end

Then /^he should be able to search itineraries$/ do
  FactoryGirl.create :itinerary, round_trip: true
  FactoryGirl.create :itinerary

  visit itineraries_path
  fill_in 'itineraries_search_from', with: 'Milan'
  fill_in 'itineraries_search_to', with: 'Turin'
  click_button 'itineraries-search'
  expect(find('.itinerary-thumbnail').size).to be 2
end
